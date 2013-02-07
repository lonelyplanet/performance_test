require 'spec_helper'

describe ResultsAggregator do

  describe '#find_percentile' do

    it 'returns 3 when given [3,2,1] and 90% percentile' do
      ResultsAggregator.find_percentile([3,2,1], 90).should == 3
    end

    it 'returns 9 when given [1,2,...10] and 90% percentile' do
      values = (1..10).to_a.shuffle
      ResultsAggregator.find_percentile(values, 90).should == 9
    end

    it 'returns 7 when given [7,3,10] and 40% percentile' do
      ResultsAggregator.find_percentile([7,3,10], 40).should == 7
    end

    it 'returns 7 when given [7,3,10] and 50% percentile' do
      ResultsAggregator.find_percentile([7,3,10], 50).should == 7
    end

    it 'returns 7 when given [7,3,10] and 74% percentile' do
      ResultsAggregator.find_percentile([7,3,10], 74).should == 7
    end

    it 'returns 10 when given [7,3,10] and 76% percentile' do
      ResultsAggregator.find_percentile([7,3,10], 76).should == 10
    end

  end
end