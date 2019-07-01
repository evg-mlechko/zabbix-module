import os, requests, json, sys
from requests.auth import HTTPBasicAuth

zabbix_server = "192.168.18.70"
zabbix_api_admin_name = "Admin"
zabbix_api_admin_password = "zabbix"
namegroup = "CloudHosts"
hostname = "Server-Agent"
ip_regisered_host = "192.168.18.100"
def post(request):
    headers = {'content-type': 'application/json'}
    return requests.post(
        "http://" + zabbix_server + "/zabbix" + "/api_jsonrpc.php",
         data=json.dumps(request),
         headers=headers,
         auth=HTTPBasicAuth(zabbix_api_admin_name, zabbix_api_admin_password)
    )

auth_token = post({
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
         "user": zabbix_api_admin_name,
         "password": zabbix_api_admin_password
     },
    "auth": None,
    "id": 0}).json()["result"]

def hostgroupcreate (namegroup, auth_token):
    return post ({"jsonrpc": "2.0",
                  "method": "hostgroup.create",
                  "params": {"name": namegroup},
                  "auth": auth_token,
                  "id": 1
                  }).json()["result"]["groupids"]

groupid = hostgroupcreate(namegroup, auth_token)

template_id = post({
    "jsonrpc": "2.0",
    "method": "template.get",
    "params": {
        "output": "extend",
        "filter": {
            "host": [
                "Template OS Linux"
            ]
        }
    },
    "auth": auth_token,
    "id": 1
}).json()['result'][0]['templateid']

def register_host(hostname, ip, groupid, template_id ):
    return post({
        "jsonrpc": "2.0",
        "method": "host.create",
        "params": {
            "host": hostname,
            "templates": [{
                "templateid": template_id
            }],
            "interfaces": [{
                "type": 1,
                "main": 1,
                "useip": 1,
                "ip": ip,
                "dns": "",
                "port": "10050"
            }],
            "groups": [
                {"groupid": groupid[0]}
            ]
        },
        "auth": auth_token,
        "id": 1
    })

register_host(hostname, ip_regisered_host, groupid, template_id )
# a = post()

