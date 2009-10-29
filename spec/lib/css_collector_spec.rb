require File.dirname(__FILE__) + '/../spec_helper'

describe CssCollector do
  describe :properties do
    it 'lists properties that have been collected' do
      collector = CssCollector.new(:width, :height, :color)

      collector.collect_attribute("width: 100px; font-family: sans-serif; height: 80px")

      (collector.properties - [:width, :height]).should == []
      ([:width, :height] - collector.properties).should == []
    end
  end

  describe :[] do
    it 'returns collected values for the property' do
      collector = CssCollector.new(:width, :height, :color)

      collector.collect_attribute("width: 100px; font-family: sans-serif; height: 80px")
      collector.collect_attribute("width: 120px;")

      collector[:width].sort.should == ["100px", "120px"]
    end

    it 'raises an error when an attribute not in the original set is requested' do
      collector = CssCollector.new(:width, :height, :color)

      collector.collect_attribute("width: 100px; font-family: sans-serif; height: 80px")

      lambda{collector['font-family']}.should raise_error
    end

    it 'returns unique matches' do
      collector = CssCollector.new(:width, :height, :color)

      collector.collect_attribute("width: 100px; font-family: sans-serif; height: 80px")
      collector.collect_attribute("width: 120px;")
      collector.collect_attribute("width: 100px; font-family: sans-serif; height: 80px")

      collector[:width].sort.should == ["100px", "120px"]
    end
  end

  describe :collect_attribute do
    it 'aggregates style attribute values' do
      collector = CssCollector.new(:width, :height)

      collector.collect_attribute("color: red; width: 100px;")
      collector.collect_attribute('width: 110px; height: 80px;')

      collector[:width].sort.should == %w{100px 110px}
      collector[:height].should == %w{80px}
    end

    it 'is tolerant about missing semicolons at the end' do
      collector = CssCollector.new(:width, :height)

      collector.collect_attribute("color: red; width: 100px")

      collector[:width].should == %w{100px}
    end

    it 'ignores comments' do
      collector = CssCollector.new(:width, :height)

      collector.collect_attribute("width: 100px; /* height: 180px; */")

      collector[:width].should == %w{100px}
      collector[:height].should == []
    end

    it 'strips !important' do
      collector = CssCollector.new(:width, :height)

      collector.collect_attribute("width: 100px !important;")

      collector[:width].should == %w{100px}
    end
  end

  describe :collect_stylesheet do
    it 'aggregates styles from rules' do
      collector = CssCollector.new(:width, :height)

      collector.collect_stylesheet <<-EOF
        body { width: 400px; }
        table
        {
          height: 500px;
          width: 300px;
        }
      EOF

      collector[:width].sort.should == %w{300px 400px}
      collector[:height].should == %w{500px}
    end

    it 'ignores comments' do
      collector = CssCollector.new(:width, :height)

      collector.collect_stylesheet <<-EOF
        body { width: 400px; }
        table
        {
          height: 500px;
          width: 300px;
        }
        div.foo
        {
          height: 510px;
          /*
          color: green;
          width: 180px;
          font-family: sans-serif;
          */
        }
      EOF

      collector[:width].sort.should == %w{300px 400px}
      collector[:height].should == %w{500px 510px}
    end

    describe 'with a url' do
      it 'aggregates styles from rules' do
        collector = CssCollector.new(:width, :height)

        collector.should_receive(:open).with('http://example.com/styles/basic.css').and_return(mock(:tmpfile, :read => <<-EOF))
          body { width: 400px; }
          table
          {
            height: 500px;
            width: 300px;
          }
          div.foo
          {
            height: 510px;
          }
        EOF

        collector.collect_stylesheet('http://example.com/styles/basic.css')

        collector[:width].sort.should == %w{300px 400px}
        collector[:height].should == %w{500px 510px}
      end
    end
  end

  describe :collect_html do
    it 'aggregates styles from style attributes' do
      collector = CssCollector.new(:width)

      collector.collect_html <<-EOF
        <html>
          <head><title>Test HTML</title></head>
          <body style='width: 300px'>
            <div style='width: 350px' />
          </body>
        </html>
      EOF

      collector[:width].sort.should == %w{300px 350px}
    end

    it 'aggregates styles from style elements' do
      collector = CssCollector.new(:width)

      collector.collect_html <<-EOF
        <html>
          <head><title>Test HTML</title></head>
          <body style='width: 300px'>
            <style>
              div {
                width: 305px;
              }
            </style>
            <div style='width: 350px' />
          </body>
        </html>
      EOF

      collector[:width].sort.should == %w{300px 305px 350px}
    end

    describe 'with a url' do
      it 'aggregates styles from style attributes' do
        collector = CssCollector.new(:width)

        collector.should_receive(:open).with('http://example.com/page.html').and_return(<<-EOF)
          <html>
            <head><title>Test HTML</title></head>
            <body style='width: 800px'>
              <div style='width: 400px' />
            </body>
          </html>
        EOF

        collector.collect_html('http://example.com/page.html')

        collector[:width].sort.should == %w{400px 800px}
      end

      it 'follows relative css links' do
        collector = CssCollector.new(:width)

        collector.should_receive(:collect_stylesheet).with('http://example.com/subdir/styles/foo.css')
        collector.should_receive(:open).with('http://example.com/subdir/page.html').and_return(<<-EOF)
          <html>
            <head>
              <link rel='stylesheet' href='styles/foo.css' />
            </head>
            <body>
            </body>
          </html>
        EOF

        collector.collect_html('http://example.com/subdir/page.html')
      end

      it 'follows relative css links when the host has a port' do
        collector = CssCollector.new(:width)

        collector.should_receive(:collect_stylesheet).with('http://example.com:8080/subdir/styles/foo.css')
        collector.should_receive(:open).with('http://example.com:8080/subdir/page.html').and_return(<<-EOF)
          <html>
            <head>
              <link rel='stylesheet' href='styles/foo.css' />
            </head>
            <body>
            </body>
          </html>
        EOF

        collector.collect_html('http://example.com:8080/subdir/page.html')
      end

      it 'follows absolute css links' do
        collector = CssCollector.new(:width)

        collector.should_receive(:collect_stylesheet).with('http://example.com/styles/foo.css')
        collector.should_receive(:open).with('http://example.com/subdir/page.html').and_return(<<-EOF)
          <html>
            <head>
              <link rel='stylesheet' href='/styles/foo.css' />
            </head>
            <body>
            </body>
          </html>
        EOF

        collector.collect_html('http://example.com/subdir/page.html')
      end

      it 'follows absolute css links when the host has a port' do
        collector = CssCollector.new(:width)

        collector.should_receive(:collect_stylesheet).with('http://example.com:8080/styles/foo.css')
        collector.should_receive(:open).with('http://example.com:8080/subdir/page.html').and_return(<<-EOF)
          <html>
            <head>
              <link rel='stylesheet' href='/styles/foo.css' />
            </head>
            <body>
            </body>
          </html>
        EOF

        collector.collect_html('http://example.com:8080/subdir/page.html')
      end

      it 'follows full url css links' do
        collector = CssCollector.new(:width)

        collector.should_receive(:collect_stylesheet).with('http://test.com/styles/foo.css')
        collector.should_receive(:open).with('http://example.com/subdir/page.html').and_return(<<-EOF)
          <html>
            <head>
              <link rel='stylesheet' href='http://test.com/styles/foo.css' />
            </head>
            <body>
            </body>
          </html>
        EOF

        collector.collect_html('http://example.com/subdir/page.html')
      end
    end
  end
end
