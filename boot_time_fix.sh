#!/bin/bash

# Disable the systemd-networkd-wait-online service
sudo systemctl disable systemd-networkd-wait-online.service

# Modify the service file to add a timeout of 1 second
sudo sed -i 's|^ExecStart=.*$|& --timeout=1|' /lib/systemd/system/systemd-networkd-wait-online.service

# Re-enable the modified service
sudo systemctl enable systemd-networkd-wait-online.service

echo "The systemd-networkd-wait-online service has been updated with a 1-second timeout."
