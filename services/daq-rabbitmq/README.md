daq-rabbitmq Helm Chart
=====================

Installs a RabbitMQ instance for use a message bus.

Deploy this chart to the cluster by setting up your cluster namespace connection
using environment.sh and then executing the following commands:

```bash
# lists the latest versions of all services
ec list
# deploy the latest version of the epics-pvcs which includes an opis volume
ec deploy daq-rabbitmq VERSION
# deploy the latest version of the epics-opis service
ec deploy daq-rabbitmq VERSION
```
