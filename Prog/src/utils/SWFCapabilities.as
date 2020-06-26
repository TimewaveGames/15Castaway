/**
 * PARA DETECTAR SE O MODO DE COMPILACAO E' DEBUG OU NAO
 * (outra forma: http://edsyrett.wordpress.com/2008/09/22/using-conditional-compilation-to-detect-debug-mode/)
 * 
 * 	With this check you can build all sorts of debugging diagnostics into your 
 * application and then compile an unaffected release build without changing any code.
 * 	There is no built in way to perform this check, so putting it modestly, the solution 
 * is a bit of a hack.  In a debug swf, the stack trace contains line number information 
 * that is absent in a release swf.  To check if you’re in debug mode, all you have to do 
 * is throw an error, catch it, and check the stack trace for the square brackets that 
 * surround the line numbers.
 * 	Here is a little class I wrote that will perform this check.
 * 
 * @author  Michael Van Daniker http://michaelvandaniker.com/blog/2008/11/25/how-to-check-debug-swf/
 */

package utils 
{
    public class SWFCapabilities
    {
        private static var hasDeterminedDebugStatus:Boolean = false;
 
        public static function get isDebug():Boolean
        {
            if(!hasDeterminedDebugStatus)
            {
                try
                {
                    throw new Error();
                }
                catch(e:Error)
                {
                    var stackTrace:String = e.getStackTrace();
                    _isDebug = stackTrace != null && stackTrace.indexOf("[") != -1;
                    hasDeterminedDebugStatus = true;
                    return _isDebug;
                }
            }
            return _isDebug;
        }
        private static var _isDebug:Boolean;
    }
}