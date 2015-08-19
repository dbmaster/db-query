import io.dbmaster.testng.BaseToolTestNGCase;

import static org.testng.Assert.assertTrue;
import org.testng.annotations.Test

import com.branegy.tools.api.ExportType;


public class DbQueryIT extends BaseToolTestNGCase {

    @Test
    public void test() {
        def parameters = [ "p_servers"  :  getTestProperty("db-query.p_servers"), 
                           "p_query"  :  getTestProperty("db-query.p_query"),]
        String result = tools.toolExecutor("db-query", parameters).execute()
    }
}
