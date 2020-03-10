class MainController < ApplicationController
  require "dropbox_sdk"

  def index
    # byebug
    client = DropboxApi::Client.new(ENV['DROPBOX_RUBY_SDK_ACCESS_TOKEN'])
    @results = client.list_folder "/recordings/20160820 אסלי"
    @url = client.get_temporary_link(@results.entries.first.path_lower).link
    # create_shared_link_with_settings
    # byebug
    # render json: results
  end
end