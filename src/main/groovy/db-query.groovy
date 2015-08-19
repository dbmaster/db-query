import java.sql.ResultSet
import java.sql.Statement
import java.sql.ResultSetMetaData

import com.branegy.dbmaster.database.api.ModelService
import com.branegy.dbmaster.model.*
import com.branegy.service.connection.api.ConnectionService
import com.branegy.dbmaster.connection.ConnectionProvider

import org.apache.commons.io.IOUtils

import com.branegy.dbmaster.connection.JdbcConnector

def rsToString(Object data){
      if (data == null) {
          return null
      } else if (data instanceof java.sql.Clob) {
          Reader reader = data.getCharacterStream();
          return IOUtils.toString(reader);
      } else {
          return data.toString()
      }
}

def printResultSet(ResultSet rs){
    ResultSetMetaData metadata = rs.getMetaData()
    int columnCount = metadata.getColumnCount()
    
    List<Object[]> result = [];
    
    println """<table cellspacing="0" class="simple-table" border="1"><tr style="background-color:#EEE">"""
    for (int i=1; i<=columnCount; ++i){
        println "<td>${metadata.getColumnName(i)}</td>"
    }
    println "</tr>"
    
    for (int i=1; i<=columnCount; ++i) {
        logger.debug("${i}:${metadata.getColumnName(i)}:${metadata.getColumnTypeName(i)}:${metadata.getColumnClassName(i)}");
    }
    
    while (rs.next()){
        Object[] row = new Object[columnCount];   
        print "<tr>"
        for (int i=1; i<=columnCount; ++i){
            row[i-1] = rsToString(rs.getObject(i))
            println "<td>${ row[i-1] }</td>"
        }
        print "</tr>"
        result.add(row)
    }
    
    println "</table><br/>"
    return result
}

def printUpdateCount(int updated){
    println "${updated} row(s) affected.<br/>"
}

connectionSrv = dbm.getService(ConnectionService.class)

def dbConnections
if (p_servers!=null && p_servers.size()>0) {
    dbConnections = p_servers.collect { serverName -> connectionSrv.findByName(serverName) }
} else {
    dbConnections  = connectionSrv.getConnectionList()
}

def showServerName = dbConnections.size()>1
result = "none";
dbConnections.each { connectionInfo ->
    try {
        def serverName = connectionInfo.getName()
        connector = ConnectionProvider.getConnector(connectionInfo)
        if (!(connector instanceof JdbcConnector)) {
            logger.info("Skipping checks for connection ${serverName} as it is not a database one")
            return
        } else {
            logger.info("Connecting to ${serverName}")
        }
        if (showServerName){
            println "<div>Server <b>${serverName}</b></div>"
        }
        
        connection = connector.getJdbcConnection(p_database)
        dbm.closeResourceOnExit(connection)
        
        Statement statement = connection.createStatement();
        dbm.closeResourceOnExit(statement)
        boolean ret = statement.execute(p_query);
        while (true){
            if (ret){
                result = printResultSet(statement.getResultSet())
            } else {
                if (statement.getUpdateCount() == -1) {
                    break;
                }
                printUpdateCount(statement.getUpdateCount())
            }
            ret = statement.getMoreResults();
        }
        connection.commit()
    } catch (Exception e) {
        def msg = "Error occurred "+e.getMessage()
        org.slf4j.LoggerFactory.getLogger(this.getClass()).error(msg,e);
        logger.error(msg, e)
        print "<div style=\"color:red;\">${e.getMessage()}</div>"
    }
    println "<br/>"
}