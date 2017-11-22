Pod::Spec.new do |s|

  s.name         = "CoachMarks"
  s.version      = "1.0.6"
  s.summary      = "CoachMarks is a component that can be used to focus the user attention on parts of the UI."

  s.description  = <<-DESC
  CoachMarks is a component, inspired by Material Design Feature Discovery guidelines, that can be used in the onboarding process of iOS applications to focus the user attention on parts of the UI.
                   DESC

  s.homepage     = "https://github.com/pNre/CoachMarks"
  s.screenshots  = "https://raw.githubusercontent.com/pNre/CoachMarks/master/Readme/Screenshots/1.png", "https://raw.githubusercontent.com/pNre/CoachMarks/master/Readme/Screenshots/Animation.gif"

  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author       = { "pNre" => "mail@pierluigi.me" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/pNre/CoachMarks.git", :tag => "#{s.version}" }
  s.source_files  = "CoachMarks/**/*.{swift}"

end
