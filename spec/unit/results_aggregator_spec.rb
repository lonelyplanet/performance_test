require 'spec_helper'

describe ResultsAggregator do

  describe '#find_percentile' do

    it 'returns 3 when given [3,2,1]' do
      ResultsAggregator.find_percentile([3,2,1], 90).should == 3
    end

    it 'returns 9 when given [1,2,...10]' do
      values = (1..10).to_a.shuffle
      ResultsAggregator.find_percentile(values, 90).should == 9
    end

  end
end