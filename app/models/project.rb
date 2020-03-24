class Project < ApplicationRecord
  include AASM
  belongs_to :owner, foreign_key: 'owner_id', class_name: "User"
  belongs_to :package
  has_many :attendances
  has_many :attendees, class_name: "User", through: :attendances

  # after_update :confirmation_email


  validates :title,
  presence: true,
  length: { in: 3..100}

  validates :short_description,
  presence: true,
  length: { in: 5..140}

  validates :attendees_goal,
  presence: true,
  numericality: { greater_than: 1, less_than: 6 }


  aasm column: :state do
    state :draft, initial: true
    state :submitted
    state :paid
    state :published
    state :finished

    event :submit do
      transitions from: :draft, to: :submitted
    end
    event :pay do
      transitions from: :submitted, to: :paid
    end
    event :publish do
      transitions from: :paid, to: :published
    end
    event :unpublish do
      transitions from: :published, to: :paid
    end
    event :end do
      transitions from: :published, to: :finished
    end
  end



def self.ongoing
    projects = self.where(state: "published")
    projects.map { |project| project.start_date <= Time.zone.now && project.end_date >= Time.zone.now ? project : nil} 
end

  def end_date
    self.start_date + (self.package.number_of_days * 86400)
  end

  def confirmation_email
    if self.state == "paid"
      UserMailer.confirmation_charge_email(self, self.owner).deliver_now
    elsif self.state == "published" 
      UserMailer.project_published_email(self, self.owner).deliver_now
      UserMailer.reminder_participation_email(self, self.owner).deliver_later(wait_until: (self.start_date - 259200))

      self.attendees.each do |attendee|
        UserMailer.reminder_participation_email(self, attendee).deliver_later(wait_until: (self.start_date - 259200))
      end
    end
  end

  
end