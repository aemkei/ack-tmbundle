require 'fileutils'

class AckInProject::SearchResults
  include AckInProject::Environment
  AckInProject::Environment.ghetto_include %w(web_preview escape), binding

  attr_accessor :plist
  
  def initialize(plist)
    self.plist = plist
  end

  def show
    puts html_head(
      :window_title => title,
      :page_title   => title,
      :html_head    => header_extra()
    )
    note = case plist['result']['ackFileType']
              when 'Normal'
                ''
              when 'All'
                ' (all types)'
              else
                ' ('+plist['result']['ackFileType']+' only)'
              end
    puts <<-HTML
      <h2>Searching for “#{ h search_string }” in #{ searched_in }#{note}</h2>
      <div id="counters"><span id="linecount">0 lines</span> matched in <span id="filecount">0 files</span></div>
      <div id="fold" style="display:none"><input type="checkbox" id="fold-toggle" accesskey="f" /><label for="fold-toggle" id="fold-lbl">Fold Results</label></div>
      <script type="text/javascript">searchStarted();</script>
    HTML

    AckInProject::Search.new(plist).search

    puts <<-HTML
      <script type="text/javascript">searchCompleted();</script>
    HTML
    html_footer
    save_buffer
  end
    
  def save_buffer
    file=AckInProject.last_result_file_name
    FileUtils.mkdir_p(File.dirname(file))
    File.open(file,"w") do |f|
      f.write $buffer
    end
  end
  
  def title 
    "Ack in Project"
  end
  
  def header_extra
    <<-HTML
      <link type="text/css" rel="stylesheet" href="file://#{e_url support_file('search.css')}" />
      <script type="text/javascript" src="file://#{e_url support_file('search.js')}" charset="utf-8"></script>
    HTML
  end
  
  def search_string
    plist['result']['returnArgument']
  end
  
  def h(string)
    CGI.escapeHTML(string)
  end
end