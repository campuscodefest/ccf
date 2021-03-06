class ProjectRating < ActiveRecord::Base
  include SlackNotifiable

  attr_accessible :project_id, :rating, :user_id

  belongs_to :project, counter_cache: true
  belongs_to :user
  has_one :organization, through: :project

  delegate :id, to: :organization, prefix: true

  def slack_message
    user_name = project.event.try(:anonymous_social) ? 'Somebody' : user.name
    "#{user_name} liked project #{project.title}: #{project.url}"
  end
end
