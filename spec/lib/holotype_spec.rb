describe Holotype do
  # Lets
  junklet *%i[
    attribute_a_name
    attribute_a_value
    attribute_b_name
    attribute_b_value
    new_attribute_b_value
  ]

  let(:instance_attribute_a) { test_instance.public_send attribute_a_name }
  let(:test_instance)        { test_class.new **instance_attributes }

  let :additional_attributes do
    Hash attribute_b_name.to_sym => new_attribute_b_value
  end

  let :instance_attributes do
    Hash[
      attribute_a_name.to_sym => attribute_a_value
    ]
  end

  let :test_class_with_basic_attribute do
    Class
      .new(described_class)
      .tap do |test_class|
        test_class.send :attribute, attribute_a_name
      end
  end

  let :test_class_with_two_attributes do
    Class
      .new(described_class)
      .tap do |test_class|
        test_class.send :attribute, attribute_a_name
        test_class.send :attribute, attribute_b_name
      end
  end

  # Class Method Tests

  describe '.attribute' do
    let(:instance_methods) { test_class.instance_methods false }
    let(:test_class)       { test_class_with_basic_attribute }

    it 'creates an accessor for the attribute' do
      expect(instance_methods).to match_array [ attribute_a_name.to_sym ]
    end

    it 'accepts the attribute in the initializer with a Symbol key' do
      expect(instance_attribute_a).to eq attribute_a_value
    end

    it 'freezes the value given in the initializer' do
      expect(instance_attribute_a).to be_frozen
    end

    context 'when given a block' do

    end
  end

  # Instance Method Tests

  describe '#frozen?' do
    let(:result)     { test_instance.frozen? }
    let(:test_class) { test_class_with_basic_attribute }

    it 'returns `true`' do
      expect(result).to be true
    end
  end

  describe '#==' do
    let(:other_instance) { test_class.new **other_attributes }
    let(:result)         { test_instance == other_instance }
    let(:test_class)     { test_class_with_two_attributes }

    context 'when the objects have equal attribute values' do
      let(:other_attributes) { instance_attributes }

      it 'returns `true`' do
        expect(result).to be true
      end
    end

    context 'when the objects have differing attribute values' do
      let(:other_attributes) { instance_attributes.merge additional_attributes }

      it 'returns `false`' do
        expect(result).to be false
      end
    end
  end

  describe '#to_hash' do
    let(:result)     { test_instance.to_hash }
    let(:test_class) { test_class_with_basic_attribute }

    it 'returns a hash of attributes and values' do
      expect(result).to eq Hash attribute_a_name.to_sym => attribute_a_value
    end

    it 'returns a hash acceptable for creating an equal instance' do
      expect(test_class.new result).to eq test_instance
    end
  end

  describe '#with' do
    let(:result)     { test_instance.with additional_attributes }
    let(:test_class) { test_class_with_two_attributes }

    it 'returns an instance with specified attributes set' do
      expect(result.send attribute_b_name).to eq new_attribute_b_value
    end

    it 'returns an instance with unspecified attributes inherited' do
      expect(result.send attribute_a_name).to eq attribute_a_value
    end
  end
end
