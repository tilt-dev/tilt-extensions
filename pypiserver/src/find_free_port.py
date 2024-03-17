import socket


def _get_free_tcp_port():
    tcp = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    tcp.bind(("", 0))
    _, port = tcp.getsockname()
    tcp.close()
    return int(port)


def _get_local_port():
    return str(_get_free_tcp_port())


print(_get_local_port())
