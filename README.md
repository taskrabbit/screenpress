# Screenpress

It happens. Your button is there but it's white on white on white and no one can see it. Especially your rspec tests.

Screenpress integrates with your Capybara tests to implement a visual regression prevention workflow.

## Setup

```ruby

# acceptance_helper.rb

require 'screenpress'

RSpec.configure do |config|
  config.include ::Screenpress::DSL
end

```

```ruby

# your_spec.rb

visit '/tasks/new'

screenpress('tasks/form')

```

This will take a picture of the page and put it at `/screenpress/tasks/form.png` to review.

## Workflow

So it just takes a screenshot and puts in in a folder. So what?

The thing is that it's now in git. If it's different, it's now on your diff and everyone can see what has changed.

You've just added a visual design review to your development process and that's cool. Now we can go back in time and see when that header changed or not accept the pull request in the first place if the button is missing.

### Options

There are a few config options...

```ruby
# acceptance_helper.rb

require 'screenpress'

# Maybe you want to turn it off in some cases (like on your continuous integration server)
Screenpress.config.enabled = false if ENV['JENKINS']

# You can change where files are saved relative to project root (default if /screenpress)
Screenpress.config.path = "/spec/screenpress"

# Or provide the full path
Screenpress.config.full_path = Rails.root.join("spec", "pictures")

RSpec.configure do |config|
  config.include ::Screenpress::DSL 
end
```

### TODO

* Allow a proc to be set for enablement
* Maybe be more deliberate like Huxley and set modes (ENV variables?) for recording
* Enable mode that fails test if image changes
* Enable tools to easily compare without Github (locally)
* Is there a good way to automatically take screenshots or when example is tagged?

### Inspiration

* [Huxley](https://github.com/facebook/huxley)
* [Wraith](https://github.com/BBC-News/wraith)
* [Green Onion](https://github.com/intridea/green_onion)
* [Capybara Screenshot](https://github.com/mattheworiordan/capybara-screenshot)
