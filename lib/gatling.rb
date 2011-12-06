require 'RMagick'

module Gatling
    class Comparison
      
      #TODO: Training mode
      #TODO: Diff with reports
      #TODO: Canidate in spec
      #TODO: Fuzz matches
      #TODO: Helpers for cucumber

      def initialize expected, actual
        @expected = expected
        @actual = actual
      end
      
      reference_image_path = reference_image_path
      puts reference_image_path
      
      def capture
        page.driver.browser.save_screenshot('temp.png')
        temp_screenshot = Magick::Image.read('temp.png').first
        # puts temp_screenshot.inspect
        # temp_screenshot.read('temp.png').first
      end

      def crop_element
        element = @actual.native
        location = element.location
        size = element.size
        capture.crop(location.x, location.y, size.width, size.height)
      end

      def save_crop_as_reference(cropped_element)   
        filename = "#{@expected}".sub(/\.[a-z]*/,'')
        cropped_element.write("#{filename}_candidate.png")
        return filename
      end   


      def matches?
        cropped_element = crop_element
        if File.exists?(@expected)
          expected_img = Magick::Image.read(@expected).first
          diff_metric = cropped_element.compare_channel(expected_img, Magick::MeanAbsoluteErrorMetric)
          matches = diff_metric[1] == 0.0
          diff_metric.first.write('diff.png') unless matches
          matches
        else
          filename = save_crop_as_reference(cropped_element)
          raise "The design reference #{@expected} does not exist, #{filename}_candidate.png is now available to be used as a reference"     
        end    
      end      
    end
    
    module Configuration

      class << self

        attr_accessor 'reference_image_path'

        def reference_image_path
           @reference_image_path ||= File.join(Rails.root, 'spec/reference_images')
        end

      end
    end  
end


  
