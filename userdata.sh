#!/bin/bash

mkdir -p /opt/cloud-portfolio

HOSTNAME=$(hostname)

cat > /opt/cloud-portfolio/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
  <title>Cloud Portfolio - HA Web App</title>
</head>
<body>
  <h1>Project 2 - Terraform AWS HA Web Application</h1>
  <p>Application server is running successfully.</p>
  <p>Served by: $HOSTNAME</p>
</body>
</html>
EOF

echo "OK" > /opt/cloud-portfolio/health

cat > /etc/systemd/system/cloud-portfolio.service <<'EOF'
[Unit]
Description=Cloud Portfolio Web Application
After=network.target

[Service]
ExecStart=/usr/bin/python3 -m http.server 80 --directory /opt/cloud-portfolio
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable cloud-portfolio.service
systemctl start cloud-portfolio.service