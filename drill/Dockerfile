FROM apache/drill

USER root

RUN cd
RUN apt update && \
    apt -y upgrade && \
    apt -y install libiodbc2 iodbc && \
    apt -y install alien && \
    wget -q http://package.mapr.com/tools/MapR-ODBC/MapR_Drill/MapRDrill_odbc_v1.5.1.1002/maprdrill-1.5.1.1002-1.el7.x86_64.rpm 
RUN alien -i maprdrill-1.5.1.1002-1.el7.x86_64.rpm 
RUN apt -y remove --purge alien && \
    apt -y autoremove && \
    rm maprdrill-1.5.1.1002-1.el7.x86_64.rpm

USER drilluser
ENV ODBCINI=/var/lib/drill/.odbc.ini
ENV APRDRILLINI=/var/lib/drill/.mapr.drillodbc.ini
ENV LD_LIBRARY_PATH=/usr/local/lib