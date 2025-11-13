#define _GNU_SOURCE
#include <security/pam_appl.h>
#include <security/pam_misc.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <poll.h>

#define PASS_MAX 512
#define TIMEOUT_MS 15000 // 15 segundos

// Para borrar memoria de forma segura
#if defined(__GLIBC__) && __GLIBC__ >= 2 && __GLIBC_MINOR__ >= 25
#define secure_bzero explicit_bzero
#else
static void secure_bzero(void *p, size_t n) {
    volatile unsigned char *vp = p;
    while (n--) *vp++ = 0;
}
#endif

struct auth_data {
    char password[PASS_MAX];
};

// Buffer para capturar mensajes de PAM (aunque no los usamos en la UI final)
static char pam_msg_buffer[1024];

static void append_pam_msg(const char *msg) {
    if (!msg) return;
    size_t cur = strlen(pam_msg_buffer);
    size_t remaining = sizeof(pam_msg_buffer) - cur - 1;
    if (remaining > 0) {
        strncat(pam_msg_buffer, msg, remaining);
    }
}

static int conv_func(int num_msg, const struct pam_message **msg,
                     struct pam_response **resp, void *appdata_ptr)
{
    struct auth_data *data = (struct auth_data *)appdata_ptr;
    struct pam_response *reply = calloc(num_msg, sizeof(struct pam_response));
    if (!reply) return PAM_CONV_ERR;

    for (int i = 0; i < num_msg; i++) {
        switch (msg[i]->msg_style) {

            case PAM_PROMPT_ECHO_OFF:
            case PAM_PROMPT_ECHO_ON:
                reply[i].resp = strdup(data->password);
                break;

            case PAM_ERROR_MSG:
            case PAM_TEXT_INFO:
                append_pam_msg(msg[i]->msg);
                reply[i].resp = NULL;
                break;

            default:
                free(reply);
                return PAM_CONV_ERR;
        }
    }

    *resp = reply;
    return PAM_SUCCESS;
}

int main(int argc, char *argv[])
{
    if (argc != 2) {
        return 100; // parámetro inválido
    }

    const char *user = argv[1];

    struct auth_data data;
    memset(&data, 0, sizeof(data));
    memset(pam_msg_buffer, 0, sizeof(pam_msg_buffer));

    // Timeout de lectura
    struct pollfd pfd = {
        .fd = STDIN_FILENO,
        .events = POLLIN
    };

    int poll_result = poll(&pfd, 1, TIMEOUT_MS);

    if (poll_result == 0)
        return 103; // timeout esperando contraseña

    if (poll_result < 0)
        return 104; // error en poll()

    if (!fgets(data.password, PASS_MAX, stdin))
        return 101; // no se pudo leer contraseña

    // Sacar salto de línea
    data.password[strcspn(data.password, "\n")] = '\0';

    pam_handle_t *pamh = NULL;
    struct pam_conv conv = { conv_func, &data };

    int ret = pam_start("login", user, &conv, &pamh);
    if (ret != PAM_SUCCESS) {
        secure_bzero(data.password, PASS_MAX);
        return 102; // error inicializando PAM
    }

    //
    // 1) Autenticación
    //
    ret = pam_authenticate(pamh, 0);

    if (ret == PAM_USER_UNKNOWN) {
        secure_bzero(data.password, PASS_MAX);
        pam_end(pamh, ret);
        return 10; // usuario inexistente
    }

    if (ret == PAM_AUTH_ERR) {
        secure_bzero(data.password, PASS_MAX);
        pam_end(pamh, ret);
        return 11; // contraseña incorrecta
    }

    if (ret != PAM_SUCCESS) {
        secure_bzero(data.password, PASS_MAX);
        pam_end(pamh, ret);
        return 12; // error genérico de autenticación
    }

    //
    // 2) Estado de cuenta
    //
    ret = pam_acct_mgmt(pamh, 0);

    if (ret == PAM_ACCT_EXPIRED) {
        secure_bzero(data.password, PASS_MAX);
        pam_end(pamh, ret);
        return 20; // cuenta expirada
    }

    if (ret == PAM_NEW_AUTHTOK_REQD) {
        secure_bzero(data.password, PASS_MAX);
        pam_end(pamh, ret);
        return 21; // necesita cambiar contraseña
    }

    if (ret == PAM_PERM_DENIED || ret == PAM_AUTH_ERR) {
        secure_bzero(data.password, PASS_MAX);
        pam_end(pamh, ret);
        return 22; // cuenta bloqueada (faillock u otra política)
    }

    if (ret != PAM_SUCCESS) {
        secure_bzero(data.password, PASS_MAX);
        pam_end(pamh, ret);
        return 23; // otro error de estado de cuenta
    }

    // Limpiar pass de memoria
    secure_bzero(data.password, PASS_MAX);

    pam_end(pamh, PAM_SUCCESS);
    return 0; // éxito total
}
