#!/bin/bash
PIDFILE=/home/GvAdmin/forever.pid
if [ -f $PIDFILE ]
then
PID=$(cat $PIDFILE)
ps -p $PID > /dev/null 2>&1
if [ $? -eq 0 ]
then
echo "Process already running"
exit 1
else
## Process not found assume not running
echo $$ > $PIDFILE
if [ $? -ne 0 ]
then
echo "Could not create PID file"
exit 1
fi
fi
else
echo $$ > $PIDFILE
if [ $? -ne 0 ]
then
echo "Could not create PID file"
exit 1
fi
fi

basePath="/grosvenor/twitter/newtwittercategoryflume/"
for filePath in $(hdfs dfs -find /grosvenor/twitter/newtwittercategoryflume/current/*.txt)
do
        epochTime=$(echo $filePath| cut -d'.' -f 2);
        epochDate=${epochTime:0:10};
        epochDateFormat=$(date -d @$epochDate +"%Y%m%d");
        transferFolder=${epochDateFormat:2:2}"-"${epochDateFormat:4:2}"-"${epochDateFormat:6:2}
        fileName="FlumeData-"${epochDateFormat:2:2}"-"${epochDateFormat:4:2}"-"${epochDateFormat:6:2}".txt"
        #transferFolder="testing";
        transferPath=$basePath$transferFolder;
        hdfsFilePath=$transferPath"/"$fileName;
        localBasePath="/opt/nodeprojects/GrosvenorLocation/scripts/moving_newdata/"
        localBasePathTxt=$localBasePath"*.txt"
        localFilePath=$localBasePath$fileName
        HDFS_COPY_HDFS_LOCAL="hdfs dfs -copyToLocal $filePath $localBasePath;"
        eval $HDFS_COPY_HDFS_LOCAL
        HDFS_MERGE="hdfs dfs -appendToFile $localBasePathTxt $hdfsFilePath"
        HDFS_CHECK="hdfs dfs -ls $hdfsFilePath"
        HDFS_PURGE="hdfs dfs -rmr -skipTrash $filePath;"
        eval $HDFS_CHECK
        if [ $? -gt 0 ]
        then
                HDFS_MKDIR="hdfs dfs -mkdir $transferPath;"
                eval $HDFS_MKDIR
                eval $HDFS_MERGE
                eval $HDFS_PURGE
        else
                eval $HDFS_MERGE
                eval $HDFS_PURGE
        fi
        rm -rf $fileName;
        rm -rf $localBasePathTxt;
done
rm $PIDFILE
