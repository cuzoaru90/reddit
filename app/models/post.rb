class Post < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user
  after_create :create_vote
  after_create :send_creator_email


  has_many :comments, dependent: :destroy

  has_many :votes, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :labelings, as: :labelable
  has_many :labels, through: :labelings

  default_scope { order('rank DESC') }

  validates :title, length: { minimum: 5 }, presence: true
  validates :body, length: { minimum: 20 }, presence: true
  validates :topic, presence: true
  validates :user, presence: true

   def up_votes
     votes.where(value: 1).count
   end
 
   def down_votes
     votes.where(value: -1).count
   end
 
   def points
     votes.sum(:value)
   end

   def update_rank
     age_in_days = (created_at - Time.new(1970,1,1)) / 1.day.seconds
     new_rank = points + age_in_days
     update_attribute(:rank, new_rank)
   end

   ## Had trouble testing private methods
    def test
      user.votes.create(value: 1, post: self)
    end

   private

   def create_vote
     user.votes.create(value: 1, post: self)
   end

   def send_creator_email
     FavoriteMailer.new_post(user).deliver_now
   end
  
end
