# encoding: utf-8
class MainController < ApplicationController
  require "dropbox_sdk"

  layout "main_show", only: [:show]

  def index
    # byebug
    @divs = []
    client = DropboxApi::Client.new(ENV['DROPBOX_RUBY_SDK_ACCESS_TOKEN'])
    results = client.list_folder("/recordings")
    # byebug
    results.entries.sort_by(&:name).reverse.each do |result|
      name_split = result.name.split(' ', 2)
      if name_split[0].scan(/\D/).empty? && name_split[0].size == 8
        date = Date.strptime(name_split[0], '%Y%m%d').strftime('%d/%m/%Y')
        name = name_split[1] || 'none'
        @divs << { date: date, name: name, path: result.name }
      else
        @divs << { date: 'unknown', name: result.name || 'none', path: result.name }
      end
    end
    respond_to do |format|
      format.html  # index.html.erb
      format.json  { render json: @divs }
    end
  end

  def show
    @wav_urls = []
    @playlist = []
    @jpg_url = nil
    @txt = ''
    client = DropboxApi::Client.new(ENV['DROPBOX_RUBY_SDK_ACCESS_TOKEN'])
    results = client.list_folder("/recordings/" + params[:path].gsub('.json', ''))
    results.entries.each do |result|
      type = result.name.split('.').last&.downcase
      case type
      when 'wav'
        @wav_urls << { name: result.name, url: client.get_temporary_link(result.path_lower).link }
        @playlist << { title: result.name.sub!('.wav', ''), wav: client.get_temporary_link(result.path_lower).link }
      when 'jpg'
        @jpg_url = client.get_temporary_link(result.path_lower).link
      when 'txt'
        client.download(result.path_lower) do |chunk|
          @txt << chunk
        end
        @txt.force_encoding('ASCII-8BIT').force_encoding('UTF-8')
        #byebug
      end
      #byebug
    end
    respond_to do |format|
      format.html  # index.html.erb
      format.json { render json: { wavs: @wav_urls, playlist: @playlist, jpg: @jpg_url, text: @txt } }
    end
  end
end