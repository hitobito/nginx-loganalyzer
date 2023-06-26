# Nginx Client Country IP Log Analyzer

## Usage

### 1. Download Log files from Kibana

1. Access your Kibana instance by Firefox
2. Open network tab in developer tools
3. Apply your search to retrieve all Nginx Log entries
4. Save response as .har file to `./logs` directory in this git repo

![firefox-screenshot](/doc/img/firefox-har.png)

### 2. Run script

`./report`
