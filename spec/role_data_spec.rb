require 'spec_helper'

describe EC2::Host::RoleData do
  describe 'initialize' do
    let(:subject) { EC2::Host::RoleData.new('web', 'test') }
    it do
      expect(subject.role1).to eq('web')
      expect(subject.role2).to eq('test')
      expect(subject.role3).to be_nil
    end
  end

  describe '#build' do
    let(:subject) { EC2::Host::RoleData.build('web:test') }
    it do
      expect(subject.role1).to eq('web')
      expect(subject.role2).to eq('test')
      expect(subject.role3).to be_nil
    end
  end

  describe '#uppers' do
    let(:subject) { EC2::Host::RoleData.build('web:test').uppers }
    it do
      expect(subject[0]).to eq('web')
      expect(subject[1]).to eq('web:test')
      expect(subject[2]).to be_nil
    end
  end

  describe '#match?' do
    let(:subject) { EC2::Host::RoleData.build('web:test') }
    it do
      expect(subject.match?('web')).to be_truthy
      expect(subject.match?('web', 'test')).to be_truthy
      expect(subject.match?('web', 'test', 'wrong')).to be_falsey
      expect(subject.match?('web', 'wrong')).to be_falsey
    end
  end
end
