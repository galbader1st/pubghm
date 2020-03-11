class MainController < ApplicationController
  require "dropbox_sdk"

  def index
    # byebug
    @divs = []
    client = DropboxApi::Client.new(ENV['DROPBOX_RUBY_SDK_ACCESS_TOKEN'])
    results = client.list_folder("/recordings")
    # byebug
    results.entries.each do |result|
      name_split = result.name.split(' ', 2)
      if name_split[0].scan(/\D/).empty? && name_split[0].size == 8
        date = Date.strptime(name_split[0], '%Y%m%d').strftime('%d/%m/%Y')
        name = name_split[1] || 'none'
        @divs << { date: date, name: name, path: result.name }
      else
        @divs << { date: 'unknown', name: result.name || 'none', path: result.name }
      end
    end
    # @url = client.get_temporary_link(@results.entries.first.path_lower).link
    # create_shared_link_with_settings
    # byebug
    # render json: results
  end

  def show
    @wav_urls = []
    client = DropboxApi::Client.new(ENV['DROPBOX_RUBY_SDK_ACCESS_TOKEN'])
    results = client.list_folder("/recordings/" + params[:path])
    results.entries.each do |result|
      type = result.name.split('.').last&.downcase
      case type
      when 'wav'
        @wav_urls << { name: result.name, url: client.get_temporary_link(result.path_lower).link }
      end
      #byebug
    end
  end
end