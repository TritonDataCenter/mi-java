# Get password from metadata unless passed as TOMCAT_PW, or set one
TOMCAT_PW=${TOMCAT_PW:-$(mdata-get tomcat_pw 2>/dev/null)} || \
TOMCAT_PW=$(od -An -N8 -x /dev/random | head -1 | tr -d ' ');

# Remove last line from tomcat-users.xml
sed -i '$ d' /opt/local/share/tomcat/conf/tomcat-users.xml

# Configure user/password for tomcat service
cat >> /opt/local/share/tomcat/conf/tomcat-users.xml <<EOF
<role rolename="manager-gui"/>
<user username="tomcat" password="${TOMCAT_PW}" roles="manager-gui,manager-script,manager-jmx,manager-status,admin-gui"/>
</tomcat-users>
EOF

# Enable tomcat service
svcadm enable tomcat

# Create the default tomcat vhost to proxy 8080 to localhost
sm-create-vhost -t apache ${PUBLIC_IP} /opt/local/share/httpd/htdocs

# Enable apache service
svcadm enable apache
