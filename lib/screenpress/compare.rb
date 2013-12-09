# based on: https://github.com/intridea/green_onion/blob/master/lib/green_onion/compare.rb

require "oily_png"

module Screenpress
  class Compare
    include ChunkyPNG::Color

    attr_reader :orig_image, :fresh_image, :threshold
    def initialize(orig_path, fresh_path, threshold)
      @orig_path  = orig_path
      @fresh_path = fresh_path
      @threshold ||= threshold
    end

    def same?
      return !File.exists?(@fresh_path) if !File.exists?(@orig_path)
      setup

      return false unless diff_iterator

      
      if percentage_diff > 0
        puts "Image Percentage Different #{@orig_path}: #{percentage_diff}"
        if percentage_diff > self.threshold
          puts "   Image different!"
          return false
        end
      end

      true
    end

    protected

    def setup
      return if @diff_index
      @orig_image  = ChunkyPNG::Image.from_file(@orig_path)
      @fresh_image = ChunkyPNG::Image.from_file(@fresh_path)
      @diff_index = []
    end


    # Pulled from Jeff Kreeftmeijer's post here: http://jeffkreeftmeijer.com/2011/comparing-images-and-creating-image-diffs/
    # Run through all of the pixels on both org image, and fresh image. Change the pixel color accordingly.
    def update_diff_index(x, y, pixel)
      lowest_score = 1
      return if pixel == fresh_image[x,y]

      # try a bit in each direction to account for differences
      [-2, -1, 0, 1, 2].each do |yd|
        [-1, 0, 1].each do |xd|
          begin
            # to do based on more nuanced score
            #score = Math.sqrt(
            #        (r(fresh_image[x+xd,y+yd]) - r(pixel)) ** 2 +
            #        (g(fresh_image[x+xd,y+yd]) - g(pixel)) ** 2 +
            #        (b(fresh_image[x+xd,y+yd]) - b(pixel)) ** 2
            #      ) / Math.sqrt(MAX ** 2 * 3)
            
            return if pixel == fresh_image[x+xd,y+yd]

            score = 1

            lowest_score = score if score < lowest_score
          rescue ChunkyPNG::OutOfBounds
            # off the edge!
          end
        end
      end
      
      @diff_index << [x,y,lowest_score] if lowest_score > 0
    end

    def diff_iterator
      orig_image.height.times do |y|
        orig_image.row(y).each_with_index do |pixel, x|
          update_diff_index(x, y, pixel)
        end
      end

      return true
    end

    # Returns the numeric results of the diff of 2 images
    def percentage_diff
      return @percentage_changed if @percentage_changed
      total_px = orig_image.pixels.length
      changed_px = @diff_index.length

      # to do based on more nuanced score
      #changed_px = 0.0
      #@diff_index.each do |x,y,score|
        # could use the actual score
      #  changed_px += score
      #end
      @percentage_changed = ((changed_px.to_f*100) / total_px)
    end

    # Saves the visual diff as a separate file
    def save_visual_diff
      x, y = @diff_index.map{ |xy| xy[0] }, @diff_index.map{ |xy| xy[1] }
      diff_path = @orig_path.insert(-5, '_diff')

      begin
        fresh_image.rect(x.min, y.min, x.max, y.max, ChunkyPNG::Color.rgb(0,255,0))
      rescue NoMethodError
        puts "Both images are the same."
      end
      
      fresh_image.save(diff_path)
    end

  end
end