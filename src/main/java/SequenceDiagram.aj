//package observer;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.io.File;
import org.aspectj.lang.*;

import net.sourceforge.plantuml.SourceStringReader;

public aspect SequenceDiagram {

	private String initial_participant,initial_method;
	private String prev_obj,next_obj;
	private  int dcount,acount = 0;
	private String method_name,class_name ;
	private String seqUML ="";
	private ArrayList<String> flow_list=new ArrayList<String>();
	
	pointcut traceMethods() : 
    	((execution(*.new(..)) || execution(* *.*(..))) && !within(SequenceDiagram));
    
    before() : traceMethods() && !within(SequenceDiagram +) {
        Signature sig = thisJoinPointStaticPart.getSignature();
       /* System.out.println("current object" + thisJoinPoint.getThis());    
        System.out.println("Entering "
                    + fullName(sig)
                    + createParameterMessage(thisJoinPoint));*/
        getDetails(thisJoinPoint,sig);
                
        }
    

    /**
     * This advice logs method leavings
     */
    after() returning : traceMethods() {
        Signature sig = thisJoinPoint.getStaticPart().getSignature();
        method_name = sig.getName();
        class_name =sig.getDeclaringType().getName();
          //  System.out.println("Leaving " + fullName(sig) + "curr_obj" + thisJoinPoint.getThis());
    	Object currnt_obj = thisJoinPoint.getThis();
    	String last_call=sig.getDeclaringType().getName() +"."+sig.getName();
		
        if(currnt_obj != null)
    	{
        	String curr_obj_str= currnt_obj.toString();
    		String[] curr = curr_obj_str.split("@");
    		String curr_obj = curr[0];
    		String search = curr_obj_str+"|"+class_name+"."+method_name;
    		if ((method_name.equals("<init>") && (class_name.equals(curr_obj))) || (!(method_name.equals("<init>"))) )
    		{
    			for(int j = flow_list.size() - 1; j >= 0; j--)
    			{
    				String curr_item = flow_list.get(j);
    				if (curr_item.contains(search))
    				{
    			//	System.out.println("return_string"+flow_list.get(j));
    				String[] data = curr_item.split("[|]"); 	
    				next_obj = data[0];
    				prev_obj = data[1];
    				seqUML += prev_obj + " --> " + next_obj+" : "+method_name + "\n";
    				seqUML += "deactivate "+curr_obj_str+"\n";
    				if (next_obj.equals(initial_participant))
    				{
    					//seqUML += "deactivate "+next_obj+"\n";
    					//seqUML += "activate "+next_obj+"\n";
    				}	
    				dcount ++;
    				break;
    				}
    				}
    		}
    	}
    		if (dcount == acount)
    		{
    			prev_obj = next_obj = initial_participant;

    		}
    		if (last_call.equals(initial_method) && currnt_obj == null )
    		{
    			seqUML += "deactivate "+sig.getDeclaringType().getName()+"\n";
    			seqUML += "@enduml";
    			System.out.println(seqUML);
    			int random = (int )(Math.random() * 50 + 1); 
    			String output_name = "output" +File.separator+ "sequence" + random;
    			drawClass(output_name,seqUML);
    		}
    }

    /**
     * This advice logs exception throwing
     */
    after() throwing(Throwable ex) : traceMethods() {
        Signature sig = thisJoinPointStaticPart.getSignature();
        System.out.println("Thrown " + "[" + sig.getDeclaringType().getName()+ "."+ sig.getName()+ "]" + "\n\t" + ex);
    }

    
    private void getDetails(JoinPoint joinpoint,Signature sig)
    {
    	Object currnt_obj = joinpoint.getThis();
    	if (currnt_obj != null)
    	{
    		String curr_obj_str= currnt_obj.toString();
    		String[] curr = curr_obj_str.split("@");
    		String curr_obj = curr[0];
    		/*System.out.println("curr_obj" + curr_obj);*/
    		method_name = sig.getName();
    		class_name =sig.getDeclaringType().getName();
    		/*System.out.println("method_name" + method_name);
    		System.out.println("sig.getDeclaringType().getName()"+sig.getDeclaringType().getName());
    		System.out.println("curr_obj"+curr_obj);
    		System.out.println("sig.getDeclaringType().getName().equals(curr_obj)"+sig.getDeclaringType().getName().equals(curr_obj));
    		System.out.println("method_name.equals(<init>)"+method_name.equals("<init>"));
    		*/
    		
    		String parameters = createParameterMessage(joinpoint);
    		
    		if (method_name.equals("<init>") && (class_name.equals(curr_obj)) )
    		{
        		prev_obj = next_obj;
        		next_obj = curr_obj_str;
    			seqUML += prev_obj + " -> " + next_obj+" : "+method_name + parameters +"\n";
    			seqUML += "activate "+next_obj+"\n";
    			acount ++;
    			String list = prev_obj + "|" +curr_obj_str + "|" +class_name+"."+method_name;
    			flow_list.add(list);
    		}
    		else if (!(method_name.equals("<init>")))
    		{
        		prev_obj = next_obj;
        		next_obj = curr_obj_str;
    			seqUML += prev_obj + " -> " + next_obj+" : "+method_name + parameters +"\n";
    			seqUML += "activate "+next_obj+"\n";
    			String list = prev_obj + "|" +curr_obj_str + "|" +class_name+"."+method_name;
    			flow_list.add(list);
    			acount ++;
    			
    		}
    	}
    	else
    	{
    		prev_obj = next_obj = sig.getDeclaringType().getName();
    		seqUML += "@startuml"+"\n";
    		seqUML += "participant "+prev_obj+"\n";
    		seqUML += "activate "+prev_obj+"\n";
    		//seqUML += "autonumber \"<b>\"" + "\n";
    		initial_participant = prev_obj;
    		initial_method=sig.getDeclaringType().getName() +"."+sig.getName();
    	}
    	
    }
    
	private void drawClass(String fname, String input) {
		OutputStream png = null;
		try {
			png = new FileOutputStream(fname);
			SourceStringReader read = new SourceStringReader(input);
			read.generateImage(png);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		catch (IOException e) {
			e.printStackTrace();
		}finally {
            if (png != null) {
                try {
                    png.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
	}

    
   /* 
    
    private String fullName(Signature sig) {
        return "["
            + sig.getDeclaringType().getName()
            + "."
            + sig.getName()
            + "]";
    }*/

    private String createParameterMessage(JoinPoint joinPoint) {
        StringBuffer paramBuffer = new StringBuffer();

  /*      if (joinPoint.getThis() != null) {
            String name = joinPoint.getStaticPart().getSignature().getName();
            if (!(name.startsWith("get"))
                && !(name.startsWith("set"))
                && !(name.equals("<init>"))) {

                paramBuffer.append("\n\t[This: ");
                paramBuffer.append(joinPoint.getThis());
                paramBuffer.append("]");
            }
        }
*/
        Object[] arguments = joinPoint.getArgs();
        if (arguments.length > 0) {
            paramBuffer.append("[");
            for (int length = arguments.length, i = 0; i < length; ++i) {
                Object argument = arguments[i];
                paramBuffer.append(argument);
                if (i != length - 1) {
                    paramBuffer.append(",");
                }
            }
            paramBuffer.append("]");
        }
        return paramBuffer.toString();
    }
}
