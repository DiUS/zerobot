class Pivotal

  attr_reader :project

  def initialize config
    PivotalTracker::Client.token = config[:token] # 3ba054f35a46ecfca092518c18daad49
    @project = PivotalTracker::Project.find(config[:project_id]) # 648011
  end
end
