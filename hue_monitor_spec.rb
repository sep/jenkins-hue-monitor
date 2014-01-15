require_relative 'hue_monitor'

describe HueMonitor, "#execute" do
  before :each do
    @notifier = double('notifier')
    @monitor = HueMonitor.new @notifier
    @some_url = "http://url"
  end

  it "should call for green if all builds are passing" do
    green = HueMonitor::colors['green']
    json = create_json [ :blue, :blue, :blue, :blue, :blue ]
    allow(@notifier).to receive(:get).and_return(json)
    expect(@notifier).to receive(:put).with(/http/, %Q/{"hue":#{green}}/, anything())
    @monitor.execute @some_url
  end

  it "should call for yellow if at least one build is building and one has failed" do
    yellow = HueMonitor::colors['yellow']
    json = create_json [ :blue, :blue_anime, :red, :blue, :blue ]
    allow(@notifier).to receive(:get).and_return(json)
    expect(@notifier).to receive(:put).with(/http/, %Q/{"hue":#{yellow}}/, anything())
    @monitor.execute @some_url
  end

  it "should call for yellow if a failed build is building" do
    yellow = HueMonitor::colors['yellow']
    json = create_json [ :blue, :red_anime, :blue, :blue, :blue ]
    allow(@notifier).to receive(:get).and_return(json)
    expect(@notifier).to receive(:put).with(/http/, %Q/{"hue":#{yellow}}/, anything())
    @monitor.execute @some_url
  end

  it "should call for blue if all are passing and at least one is building" do
    blue = HueMonitor::colors['blue']
    json = create_json [ :blue, :blue, :blue_anime, :blue, :blue_anime ]
    allow(@notifier).to receive(:get).and_return(json)
    expect(@notifier).to receive(:put).with(/http/, %Q/{"hue":#{blue}}/, anything())
    @monitor.execute @some_url
  end

  it "should call for red if any are failing and none are building" do
    red = HueMonitor::colors['red']
    json = create_json [ :blue, :blue, :blue, :red, :blue ]
    allow(@notifier).to receive(:get).and_return(json)
    expect(@notifier).to receive(:put).with(/http/, %Q/{"hue":#{red}}/, anything())
    @monitor.execute @some_url
  end

  def create_json colors
    d = '"description":null'
    n = '"name":"builds"'
    p = '"property":[]'
    u = '"url":"http://jenkins/view/Builds/"'
    builds = colors.each_with_index.map do |color, index|
      b = "build%03d" % index
      c = color.to_s
      %Q({"name":"#{b}","url":"http://jenkins/job/#{b}/","color":"#{c}"})
    end

    %Q({#{d},"jobs":[#{builds.join ','}],#{n},#{p},#{u}})
  end
end
