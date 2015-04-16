require "sidekiq"
require "awesome_print"

class ProjWorker
  include Sidekiq::Worker
  def perform(home_id)
    # set requestor status flag ("WAIT: Scanning <path> for projects"
    # get home from es
    # stop if home is not active
    # check if path is accessible
    # clear all projects in es for this home
    # scan path for projects
    # add found projects
    # set requestor status flag ("DONE: Found 10 projects in <path>

  end
end
