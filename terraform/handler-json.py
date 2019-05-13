#part-handler
#This is a part handler to deal with the application/json
#  mime type in the cloud-init code
# https://cloudinit.readthedocs.io/en/latest/topics/format.html#part-handler
def list_types():
    # we handle json var data here
    return(["application/json"])

def handle_part(data,ctype,filename,payload):
    if ctype == "__begin__":
       print("starting JSON handler")
       return
    if ctype == "__end__":
       print("done JSON handler")
       return

    print("==== received ctype=%s filename=%s ====" % (ctype,filename))
    f = open("/run/cloud-init/" + filename,"wb")
    f.write(payload)
    f.close()
    print("==== end ctype=%s filename=%s" % (ctype, filename))
