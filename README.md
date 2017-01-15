# LiMon for POWER (ppc64le)

LiMon stands for "**Li**nux **Mon**itoring system".

It is just the integration a several open-source project we use to monitor performances of several Linux servers during PoC, demos etc..

1. **Grafana:** [http://grafana.org](http://grafana.org).  
Grafana is the frontend used for graphique generation and visualisation.

2. **Graphite:** [https://graphiteapp.org](https://graphiteapp.org).  
Graphite is used as a datasource for grafana. It is a fixed sized database based on the RRD. It is pretty conveniente to use with **grafana** (very powerfull query tool) and is compatible with a lot of performance collector we can find on Linux such as [collectd](https://collectd.org).  

3. **Statsd:** [https://github.com/etsy/statsd](https://github.com/etsy/statsd).  
Statsd is a network daemon that listen for statistics like counters sended over TCP or UDP. It can collect and aggregate those value and send them in a backend like **Graphite**. In **LiMon**, it offers you another way to send customized values (through scripts) to the graphite backend. 

4. **Influxdb** [https://www.influxdata.com/time-series-platform/influxdb](https://www.influxdata.com/time-series-platform/influxdb/).  
InfluxDB is a timeserie database used in **LiMon** as a datasource for Grafana. Compare to Graphite, its query system is more SQL based but less convenient and powerfull than **graphite**. On the other hand, it has a better scalability (less IOs) so it can sustain higher refresh rate than Graphite.  
*(__Note:__ you can use both **Graphite** and **InfluxDB** datasource at the same time in **Grafana** to leverage best capabilities of each datasource system.)*

5. **Memcached** [https://memcached.org/](https://memcached.org/).  
Memcached is an open source in-memory object caching system. In our case, we are using it to store graphite-web query results to improve performance during graphics manipulation in grafana.


```
                       [Memcached] (query results)     
                            ^
                            |
User --> [Grafana] <-- [Gaphite] <----------- Data from Servers (collectd).  
             ^              ^  
             |              |_ [statsd] <---- Data from Servers (scripts).  
             |
             |________________ [InfluxDB] <-- Data from Servers (RestAPI).
```

To make it easier to install, all those different component were "containerized"
 with docker.
 
 | service name | (host port):(docker port) |
 |:------------:|:-------------------------:| 
 |grafana|
 
## 1. Installation

Here is the way to install your Linux Monitoring system (LiMon).

Prepare a Linux on Power VM witn ubuntu (16.04 prefered) and clone this repository.  
`git clone https://github.com/schabrolles/LiMon.git`

Then, enter in the LiMon directory and start installation.   
`./install.sh`
