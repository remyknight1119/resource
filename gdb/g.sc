file /bin/httproxy-ssl
set detach-on-fork off
catch fork
r -f /tmp/vs/root/ssl.0.httproxy.cfg
cont
info inferiors
inferior 2
cont
end
run
