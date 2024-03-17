import sys
import socket


def _is_port_in_use(port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    in_use = s.connect_ex(("127.0.0.1", port)) == 0
    s.close()
    return in_use


port = sys.argv[1]
if not port:
    print("ERROR: You must specify port number!!!") 
    sys.exit(1)
print("true" if _is_port_in_use(int(port)) else "false")
