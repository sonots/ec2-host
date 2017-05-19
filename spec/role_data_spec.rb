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
    context 'with single match' do
      let(:subject) { EC2::Host::RoleData.build('admin:jenkins:slave') }

      it do
        expect(subject.match?('admin')).to be_truthy
        expect(subject.match?('admin', 'jenkins')).to be_truthy
        expect(subject.match?('admin', 'jenkins', 'slave')).to be_truthy
        expect(subject.match?(nil, 'jenkins')).to be_truthy
        expect(subject.match?(nil, nil, 'slave')).to be_truthy

        expect(subject.match?('wrong')).to be_falsey
        expect(subject.match?('admin', 'wrong')).to be_falsey
        expect(subject.match?('admin', 'jenkins', 'wrong')).to be_falsey
        expect(subject.match?(nil, 'wrong')).to be_falsey
        expect(subject.match?(nil, nil, 'wrong')).to be_falsey
      end
    end


    context 'with array match' do
      it do
        expect(EC2::Host::RoleData.build('foo:a').match?(['foo', 'bar'])).to be_truthy
        expect(EC2::Host::RoleData.build('bar:a').match?(['foo', 'bar'])).to be_truthy
        expect(EC2::Host::RoleData.build('baz:a').match?(['foo', 'bar'])).to be_falsey

        expect(EC2::Host::RoleData.build('foo:a').match?(['foo', 'bar'], ['a', 'b'])).to be_truthy
        expect(EC2::Host::RoleData.build('bar:a').match?(['foo', 'bar'], ['a', 'b'])).to be_truthy
        expect(EC2::Host::RoleData.build('baz:a').match?(['foo', 'bar'], ['a', 'b'])).to be_falsey
        expect(EC2::Host::RoleData.build('foo:b').match?(['foo', 'bar'], ['a', 'b'])).to be_truthy
        expect(EC2::Host::RoleData.build('bar:b').match?(['foo', 'bar'], ['a', 'b'])).to be_truthy
        expect(EC2::Host::RoleData.build('baz:b').match?(['foo', 'bar'], ['a', 'b'])).to be_falsey

        expect(EC2::Host::RoleData.build('foo:a').match?(nil, ['a', 'b'])).to be_truthy
      end
    end
  end
end
