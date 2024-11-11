module Fts
  include NWFeature
  include NWFeature::PartyEx
  include NWFeature::Battler
  include NWFeature::Booster
  
  def features(code); end

  def features_with_id(code, id); end

  def features_pi(code, id)
    features_with_id(code, id).inject(1.0) { |r, ft| r *= ft.value }
  end

  def features_sum(code, id)
    features_with_id(code, id).inject(0.0) { |r, ft| r += ft.value }
  end

  def features_sum_all(code)
    features(code).inject(0.0) { |r, ft| r + ft.value }
  end

  def features_set(code)
    features(code).inject([]) { |r, ft| r | [ft.data_id] }
  end

  def features_max(code, id)
    features_with_id(code, id).inject(0.0) { |r, ft| r < ft.value ? ft.value : r }
  end

  def features_min(code, id)
    features_with_id(code, id).inject(1.0) { |r, ft| r > ft.value ? ft.value : r }
  end

  def features_sum_booster(feature_id, data_id)
    features_with_id(FEATURE_MULTI_BOOSTER, feature_id).inject(0.0) do |sum, ft|
      ft.value.key?(data_id) ? sum + ft.value[data_id] : sum
    end
  end
end

module Hima
  class FeatureObjects
    include Enumerable
    include Fts

    def initialize(feature_objects)
      @feature_objects = feature_objects
    end

    def all_features
      @feature_objects.map(&:features).flatten
    end

    def +(other)
      case other
      when Array
        FeatureObjects.new(@feature_objects + other)
      when FeatureObjects
        FeatureObjects.new(@feature_objects + other.instance_variable_get(:@feature_objects))
      end
    end

    def features(code)
      @feature_objects.map { |obj| obj.feature_data.fetch(code, {}).values }.flatten
    end

    def features_with_id(code, id)
      @feature_objects.map { |obj| obj.feature_data.fetch(code, {}).fetch(id, []) }.flatten
    end

    def each(&block)
      @feature_objects.each(&block)
    end
  end
end