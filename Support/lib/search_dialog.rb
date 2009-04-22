# NOTE: To get values put into plist['result'], they need to be put into the bindings for the "Find"
# button. *Including* the "Selector Name" for "Target".
# This is probably intuitive to experienced Cocoa programmers. I am not one. ~David

class AckInProject::SearchDialog
  include AckInProject::Environment
  AckInProject::Environment.ghetto_include %w(web_preview), binding
  
  def show(&block)
    raise ArgumentError, 'show_search_dialog requires a block' if block.nil?

    verify_project_directory or return
    
    command = %Q{#{TM_DIALOG} -cm -p #{e_sh params.to_plist} -d #{e_sh defaults.to_plist} #{e_sh nib_file('AckInProjectSearch.nib')}}
    plist = OSX::PropertyList::load(%x{#{command}})
    if plist['result']
      block.call(plist)
    else
      last_result_file=AckInProject.last_result_file_name
      if File.exists?(last_result_file)
        puts File.read(last_result_file)
      end
    end
  end
  
  def defaults
    %w(
      ackMatchWholeWords ackIgnoreCase ackLiteralMatch 
      ackShowContext ackFollowSymlinks ackLoadAckRC
    ).inject({'ackFileType'=>'Normal'}) do |hsh,v|
      hsh[v] = false
      hsh
    end
  end
  
  def params
    {
      'ackExpression' => AckInProject.pbfind,
      'ackHistory' => AckInProject.search_history,
      'ackFileTypes' => filetypes,
    }
  end
  
  def verify_project_directory
    return true if project_directory
    
    puts <<-HTML
    <html><body>
      <h1>Can't determine project directory (TM_PROJECT_DIR)</h1>
    </body></html>
    HTML
  end
  
  def filetypes
    # I'm sure there's a better way to pass these to the NIB than an array of objects... but I'm not familiar with it.
    %x{#{e_sh ack} --help=types}.scan(/--\[no\]([^ ]+)/).unshift(['Normal'], ['All']).map{ |type_array| {'filetype'=>type_array[0],} }
  end
end


