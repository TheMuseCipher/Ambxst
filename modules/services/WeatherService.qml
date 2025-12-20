pragma Singleton
import QtQuick
import Quickshell.Io
import qs.config

QtObject {
    id: root

    // Current weather data
    property string weatherSymbol: ""
    property real currentTemp: 0
    property real maxTemp: 0
    property real minTemp: 0
    property int weatherCode: 0
    property real windSpeed: 0
    property bool dataAvailable: false

    // Sun position data
    property string sunrise: ""  // HH:MM format
    property string sunset: ""   // HH:MM format
    property real sunProgress: 0.0  // 0.0-1.0 position on the arc
    property bool isDay: true
    property string timeOfDay: "Day"  // "Day", "Evening", "Night"
    property string weatherDescription: ""

    // Internal state
    property int retryCount: 0
    property int maxRetries: 5
    property string cachedLat: ""
    property string cachedLon: ""

    function getWeatherDescription(code) {
        if (code === 0) return "Clear sky";
        if (code === 1) return "Mainly clear";
        if (code === 2) return "Partly cloudy";
        if (code === 3) return "Overcast";
        if (code === 45) return "Foggy";
        if (code === 48) return "Rime fog";
        if (code >= 51 && code <= 53) return "Light drizzle";
        if (code === 55) return "Dense drizzle";
        if (code >= 56 && code <= 57) return "Freezing drizzle";
        if (code === 61) return "Light rain";
        if (code === 63) return "Moderate rain";
        if (code === 65) return "Heavy rain";
        if (code >= 66 && code <= 67) return "Freezing rain";
        if (code === 71) return "Light snow";
        if (code === 73) return "Moderate snow";
        if (code === 75) return "Heavy snow";
        if (code === 77) return "Snow grains";
        if (code >= 80 && code <= 81) return "Rain showers";
        if (code === 82) return "Heavy showers";
        if (code >= 85 && code <= 86) return "Snow showers";
        if (code === 95) return "Thunderstorm";
        if (code >= 96 && code <= 99) return "Thunderstorm with hail";
        return "Unknown";
    }

    function parseTime(timeStr) {
        // Parse "HH:MM" to minutes since midnight
        var parts = timeStr.split(":");
        return parseInt(parts[0]) * 60 + parseInt(parts[1]);
    }

    function calculateSunPosition() {
        var now = new Date();
        var currentMinutes = now.getHours() * 60 + now.getMinutes();

        if (!sunrise || !sunset) {
            root.isDay = (now.getHours() >= 6 && now.getHours() < 18);
            root.sunProgress = root.isDay ? 0.5 : 0.5;
            root.timeOfDay = root.isDay ? "Day" : "Night";
            return;
        }

        var sunriseMinutes = parseTime(sunrise);
        var sunsetMinutes = parseTime(sunset);
        
        // Define golden hour (roughly 1 hour before sunset)
        var goldenHourStart = sunsetMinutes - 60;
        // Define twilight end (roughly 1 hour after sunset)
        var twilightEnd = sunsetMinutes + 60;
        // Define dawn start (roughly 1 hour before sunrise)
        var dawnStart = sunriseMinutes - 60;

        if (currentMinutes >= sunriseMinutes && currentMinutes <= sunsetMinutes) {
            // Daytime: sun moves along the arc
            root.isDay = true;
            root.sunProgress = (currentMinutes - sunriseMinutes) / (sunsetMinutes - sunriseMinutes);
            
            if (currentMinutes >= goldenHourStart) {
                root.timeOfDay = "Evening";
            } else {
                root.timeOfDay = "Day";
            }
        } else {
            // Nighttime
            root.isDay = false;
            
            if (currentMinutes > sunsetMinutes) {
                // After sunset
                if (currentMinutes <= twilightEnd) {
                    root.timeOfDay = "Evening";
                } else {
                    root.timeOfDay = "Night";
                }
                // Moon rises at sunset, sets at sunrise (simplified)
                var nightDuration = (24 * 60 - sunsetMinutes) + sunriseMinutes;
                var nightElapsed = currentMinutes - sunsetMinutes;
                root.sunProgress = nightElapsed / nightDuration;
            } else {
                // Before sunrise
                if (currentMinutes >= dawnStart) {
                    root.timeOfDay = "Day";  // Dawn
                } else {
                    root.timeOfDay = "Night";
                }
                var nightDuration = (24 * 60 - sunsetMinutes) + sunriseMinutes;
                var nightElapsed = (24 * 60 - sunsetMinutes) + currentMinutes;
                root.sunProgress = nightElapsed / nightDuration;
            }
        }
    }

    function getWeatherCodeEmoji(code) {
        if (code === 0)
            return "☀️";
        if (code === 1)
            return "🌤️";
        if (code === 2)
            return "⛅";
        if (code === 3)
            return "☁️";
        if (code === 45)
            return "🌫️";
        if (code === 48)
            return "🌨️";
        if (code >= 51 && code <= 53)
            return "🌦️";
        if (code === 55)
            return "🌧️";
        if (code >= 56 && code <= 57)
            return "🧊";
        if (code >= 61 && code <= 65)
            return "🌧️";
        if (code >= 66 && code <= 67)
            return "🧊";
        if (code >= 71 && code <= 77)
            return "❄️";
        if (code >= 80 && code <= 81)
            return "🌦️";
        if (code === 82)
            return "🌧️";
        if (code >= 85 && code <= 86)
            return "🌨️";
        if (code === 95)
            return "⛈️";
        if (code >= 96 && code <= 99)
            return "🌩️";
        return "❓";
    }

    function convertTemp(temp) {
        if (Config.weather.unit === "F") {
            return (temp * 9 / 5) + 32;
        }
        return temp;
    }

    function fetchWeatherWithCoords(lat, lon) {
        var url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat + "&longitude=" + lon + "&current_weather=true&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset&timezone=auto";
        weatherProcess.command = ["curl", "-s", url];
        weatherProcess.running = true;
    }

    function urlEncode(str) {
        return str.replace(/%/g, "%25").replace(/ /g, "%20").replace(/!/g, "%21").replace(/"/g, "%22").replace(/#/g, "%23").replace(/\$/g, "%24").replace(/&/g, "%26").replace(/'/g, "%27").replace(/\(/g, "%28").replace(/\)/g, "%29").replace(/\*/g, "%2A").replace(/\+/g, "%2B").replace(/,/g, "%2C").replace(/\//g, "%2F").replace(/:/g, "%3A").replace(/;/g, "%3B").replace(/=/g, "%3D").replace(/\?/g, "%3F").replace(/@/g, "%40").replace(/\[/g, "%5B").replace(/]/g, "%5D");
    }

    function updateWeather() {
        var location = Config.weather.location.trim();
        if (location.length === 0) {
            geoipProcess.command = ["curl", "-s", "https://ipapi.co/json/"];
            geoipProcess.running = true;
            return;
        }

        var coords = location.split(",");
        var isCoordinates = coords.length === 2 && !isNaN(parseFloat(coords[0].trim())) && !isNaN(parseFloat(coords[1].trim()));

        if (isCoordinates) {
            cachedLat = coords[0].trim();
            cachedLon = coords[1].trim();
            fetchWeatherWithCoords(cachedLat, cachedLon);
        } else {
            var encodedCity = urlEncode(location);
            var geocodeUrl = "https://geocoding-api.open-meteo.com/v1/search?name=" + encodedCity;
            geocodingProcess.command = ["curl", "-s", geocodeUrl];
            geocodingProcess.running = true;
        }
    }

    property Process geoipProcess: Process {
        running: false
        command: []

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var raw = text.trim();
                if (raw.length > 0) {
                    try {
                        var data = JSON.parse(raw);
                        if (data.latitude && data.longitude) {
                            root.cachedLat = data.latitude.toString();
                            root.cachedLon = data.longitude.toString();
                            root.fetchWeatherWithCoords(root.cachedLat, root.cachedLon);
                        } else {
                            root.dataAvailable = false;
                        }
                    } catch (e) {
                        root.dataAvailable = false;
                    }
                }
            }
        }

        onExited: function (code) {
            if (code !== 0) {
                root.dataAvailable = false;
            }
        }
    }

    property Process geocodingProcess: Process {
        running: false
        command: []

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var raw = text.trim();
                if (raw.length > 0) {
                    try {
                        var data = JSON.parse(raw);
                        if (data.results && data.results.length > 0) {
                            var result = data.results[0];
                            root.cachedLat = result.latitude.toString();
                            root.cachedLon = result.longitude.toString();
                            root.fetchWeatherWithCoords(root.cachedLat, root.cachedLon);
                        } else {
                            root.dataAvailable = false;
                        }
                    } catch (e) {
                        root.dataAvailable = false;
                    }
                }
            }
        }

        onExited: function (code) {
            if (code !== 0) {
                root.dataAvailable = false;
            }
        }
    }

    property Process weatherProcess: Process {
        running: false
        command: []

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var raw = text.trim();
                if (raw.length > 0) {
                    try {
                        var data = JSON.parse(raw);
                        if (data.current_weather && data.daily) {
                            var weather = data.current_weather;
                            var daily = data.daily;
                            
                            root.weatherCode = parseInt(weather.weathercode);
                            root.currentTemp = convertTemp(parseFloat(weather.temperature));
                            root.windSpeed = parseFloat(weather.windspeed);
                            
                            // Get today's max/min temps
                            if (daily.temperature_2m_max && daily.temperature_2m_max.length > 0) {
                                root.maxTemp = convertTemp(parseFloat(daily.temperature_2m_max[0]));
                            }
                            if (daily.temperature_2m_min && daily.temperature_2m_min.length > 0) {
                                root.minTemp = convertTemp(parseFloat(daily.temperature_2m_min[0]));
                            }

                            // Get sunrise/sunset times
                            if (daily.sunrise && daily.sunrise.length > 0) {
                                // Format: "2024-12-20T07:45" -> "07:45"
                                var sunriseStr = daily.sunrise[0];
                                root.sunrise = sunriseStr.split("T")[1];
                            }
                            if (daily.sunset && daily.sunset.length > 0) {
                                var sunsetStr = daily.sunset[0];
                                root.sunset = sunsetStr.split("T")[1];
                            }

                            root.weatherSymbol = getWeatherCodeEmoji(root.weatherCode);
                            root.weatherDescription = getWeatherDescription(root.weatherCode);
                            root.calculateSunPosition();
                            root.dataAvailable = true;
                            root.retryCount = 0;
                        } else {
                            root.dataAvailable = false;
                            if (root.retryCount < root.maxRetries) {
                                root.retryCount++;
                                retryTimer.interval = Math.min(600000, 5000 * Math.pow(2, root.retryCount - 1));
                                retryTimer.start();
                            }
                        }
                    } catch (e) {
                        console.warn("WeatherService: JSON parse error:", e);
                        root.dataAvailable = false;
                        if (root.retryCount < root.maxRetries) {
                            root.retryCount++;
                            retryTimer.interval = Math.min(600000, 5000 * Math.pow(2, root.retryCount - 1));
                            retryTimer.start();
                        }
                    }
                }
            }
        }

        onExited: function (code) {
            if (code !== 0) {
                root.dataAvailable = false;
                if (root.retryCount < root.maxRetries) {
                    root.retryCount++;
                    retryTimer.interval = Math.min(600000, 5000 * Math.pow(2, root.retryCount - 1));
                    retryTimer.start();
                }
            }
        }
    }

    property Timer retryTimer: Timer {
        repeat: false
        running: false
        onTriggered: root.updateWeather()
    }

    property Timer refreshTimer: Timer {
        // Periodic weather refresh (every 10 minutes)
        interval: 600000
        running: true
        repeat: true
        onTriggered: root.updateWeather()
    }

    property Timer sunPositionTimer: Timer {
        // Update sun position every minute
        interval: 60000
        running: root.dataAvailable
        repeat: true
        onTriggered: root.calculateSunPosition()
    }

    property Connections configConnections: Connections {
        target: Config.weather
        function onLocationChanged() {
            root.updateWeather();
        }
        function onUnitChanged() {
            root.updateWeather();
        }
    }

    Component.onCompleted: {
        updateWeather();
    }
}
