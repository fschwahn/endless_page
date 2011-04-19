This tutorial shows how to create infinite scrolling pages using Kaminari. It uses [jQuery](http://jquery.com/) and [sausage](http://christophercliff.github.com/sausage/) to achieve this.

Create a new rails application. We will be using jQuery, so skip the prototype files.
```sh
$ rails new endless_page -J
```

Add 'jquery-rails' and 'kaminari' to the Gemfile and run the `bundle` command. Run the jQuery-generator to download the necessary files and setup rails to use jQuery.
```sh
$ rails generate jquery:install --ui
```

Download 'jquery.sausage' and add it along with 'jquery' and 'jquery-ui' to your `javascript_include_tag`.
```sh
$ curl -o public/javascripts/jquery.sausage.js http://christophercliff.github.com/sausage/jquery.sausage.js
```

Let's create a model, which will be used to showcase the endless scrolling and migrate the database.
```sh
$ rails generate scaffold Article title:string author:string body:text
$ rake db:migrate
```
I use the [populator](https://github.com/ryanb/populator) and [ffaker](https://github.com/EmmanuelOga/ffaker) gems to fill the database with random data, but this step is only required for showcasing the infinite scrolling. Run `rake db:populate` if you want to do the same.

In the next step we have to edit the scaffolded controller. We update the index-action so it looks like that:
```ruby
def index
  @articles = Article.order(:created_at).page(params[:page])

  respond_to do |format|
    format.js
    format.html # index.html.erb
    format.xml  { render :xml => @articles }
  end
end
```

We are now using pagination powered by Kaminari in the index action. We also make sure that our index-action responds to requests sent from Javascript. In the next step we move the rendering of an article into a partial named '_article.html.erb'. Mine looks like this:
```ruby
<div class='article'>
  <h3><%= article.title %></h3>
  <div class='author'>by <%= article.author %></div>
  <div class='date'>by <%= article.created_at.to_s(:long) %></div>
  <p>
    <%= article.body %>
  </p>
</div>
```

We can now use this partial to render the articles in 'index.html.erb' using the following command. The div with a class of 'page' is important for sausage. It is used to determine the pages.
```ruby
<div id='articles'>
  <div class='page'>
    <%= render @articles %>
  </div>
</div>
```

Now it is time to use sausage to implement the endless pagination. Add the following to the bottom of 'index.html.erb'.
```js
<script type="text/javascript">
(function() {
  var page = 1,
      loading = false;
  
  function nearBottomOfPage() {
    return $(window).scrollTop() > $(document).height() - $(window).height() - 200;
  }

  $(window).scroll(function(){
    if (loading) {
      return;
    }
    
    if(nearBottomOfPage()) {
      loading=true;
      page++;
      $.ajax({
        url: '/articles?page=' + page,
        type: 'get',
        dataType: 'script',
        success: function() {
          $(window).sausage('draw');
          loading=false;
        }
      });
    }
  });
    
  $(window).sausage();
}());
</script>
```

The snippet is pretty straightforward. It checks if the user scrolled to the bottom of the page. If that is the case, an ajax-request is sent to the `ArticlesController` requesting the next page. After the ajax-request is completed successfully the sausage-navigation is redrawn. One last piece is missing. When the ajax-request is sent to the `ArticlesController` we need to append the next page of articles. We need to create a file named 'index.js.erb' to achieve this goal.
```js
$("#articles").append("<div class='page'><%= escape_javascript(render(@articles)) %></div>");
```

## Notes
* The code for this example application can be found [here](https://www.github.com/fschwahn/endless_page).
* This tutorial was inspired by [Railscast episode 114](http://railscasts.com/episodes/114-endless-page).
* If you want to use this in production, it is recommended to minify sausage.