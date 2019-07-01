export JAVA_OPTS="-Dcom.sun.management.jmxremote=true \
                  -Dcom.sun.management.jmxremote.port=12345 \
                  -Dcom.sun.management.jmxremote.rmi.port=12346 \
                  -Dcom.sun.management.jmxremote.ssl=false \
                  -Dcom.sun.management.jmxremote.authenticate=false \
                  -Djava.rmi.server.hostname=192.168.18.70"





export CATALINA_OPTS=" \
                  -Xms256M \
                  -Xmx512M \
                  -XX:+HeapDumpOnOutOfMemoryError \
                  -XX:HeapDumpPath=/opt/tomcat/logs/dump \
                  -XX:+PrintGCDetails \
                  -Xloggc:/opt/tomcat/logs/gc.log"
