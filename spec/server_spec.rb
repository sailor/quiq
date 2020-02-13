RSpec.describe Quiq::Server do
  let(:options) { { path: Dir.pwd, queues: %w[default], log_level: Logger::DEBUG } }

  describe '#run!' do
    after { Quiq.boot(options) }

    context 'Listening on one queue only' do
      it 'starts the server when we boot the app' do
        expect(described_class.instance).to receive(:run!)
      end

      it 'spawns 1 worker + 1 scheduler' do
        expect(described_class.instance).to receive(:fork).twice
      end
    end

    context 'Listening on multiple queues' do
      let(:options) { super().merge(queues: %w[foo bar baz]) }

      it 'spawns 3 workers + 1 scheduler' do
        expect(described_class.instance).to receive(:fork).exactly(4).times
      end
    end
  end
end
