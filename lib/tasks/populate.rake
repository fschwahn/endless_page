namespace :db do
  desc "Erase and fill database"
  task :populate => :environment do
    Article.delete_all
    Article.populate 300 do |article|
      article.title = Populator.words(3..10).titleize
      article.author = Faker::Name.name
      article.body = Populator.sentences(5..30)
      article.created_at = 2.years.ago..Time.now
    end
  end
end