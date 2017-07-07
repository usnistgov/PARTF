#import socket
from struct import unpack

def SendPacket (socket,string):
    str_length = len(string)
    if str_length < pow(2,32)-4:
        msb = (str_length >> 24) & 0xff
        mhsb = (str_length >> 16) & 0xff
        mlsb = (str_length >> 8) & 0x0ff
        lsb = str_length & 0xff    
        try:        
            socket.sendall(chr(msb)+chr(mhsb)+chr(mlsb)+chr(lsb)+string)
        except IOError as e:
            raise e

    else:
        raise Exception('Data length: ',str_length,' is too long.  Must be less than ',pow(2,16)-2,'  characters.')
        
    
def ReceivePacket (socket):
    try:
        flatlen = socket.recv(4)
        datalen = (unpack('!I',flatlen))[0]
        #data = socket.recv(datalen); print len(data)
        return RecvAll(socket, datalen)
    except IOError as e:
        raise e
        
def RecvAll (socket, size):
    data = ''
    while len(data) < size:
        packet = socket.recv(size -len(data))
        if not packet:
            return None
        data += packet
    return data
    