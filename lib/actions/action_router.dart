import '../ce/wol_client.dart';
import '../models/command_result.dart';
import '../nx/nx_command.dart';
import '../nx/nx_connection.dart';
import 'action_models.dart';
import 'interlock_manager.dart';

class ActionRouter {
  ActionRouter({
    required NxConnection nx,
    required InterlockManager interlock,
    required WolClient wol,
    required ActionDef? Function(String id) resolve,
  })  : _nx = nx,
        _interlock = interlock,
        _wol = wol,
        _resolve = resolve;

  final NxConnection _nx;
  final InterlockManager _interlock;
  final WolClient _wol;
  final ActionDef? Function(String id) _resolve;

  ActionDef? lookup(String actionId) => _resolve(actionId);

  bool requiresConfirm(String actionId) => _resolve(actionId)?.confirm ?? false;

  String confirmMessage(String actionId) {
    final def = _resolve(actionId);
    return def?.confirmMessage ?? '이 동작을 실행하시겠습니까?';
  }

  Future<CommandResult> run(String actionId) {
    final def = _resolve(actionId);
    if (def == null) {
      return Future.value(CommandResult.fail('정의되지 않은 동작입니다: $actionId'));
    }
    return switch (def) {
      IrAction() => _nx.send(NxCommand.ir(def.irPort, def.ch)),
      RelayAction() => _interlock.executeRelay(def),
      SerialAction() => _nx.send(NxCommand.serial(def.port, def.message)),
      IoAction() => _nx.send(NxCommand.io(def.port, def.ch, def.value)),
      WolAction() => _wol.wake(def.mac, name: def.name),
      MacroAction() => _runMacro(def),
    };
  }

  Future<CommandResult> _runMacro(MacroAction macro) async {
    if (macro.steps.isEmpty) {
      return CommandResult.fail('등록된 PC가 없습니다. 설정에서 추가하세요.');
    }

    final sent = <String>[];
    var sawWarning = false;

    for (var i = 0; i < macro.steps.length; i++) {
      final step = macro.steps[i];
      final result = await run(step.actionId);
      sent.addAll(result.sentCommands);

      if (!result.success) {
        return CommandResult.fail(
          '매크로 실패: ${i + 1}단계(${step.actionId}) - ${result.message}',
          sentCommands: sent,
        );
      }
      if (result.isWarning) sawWarning = true;

      if (step.delayAfterMs > 0) {
        await Future<void>.delayed(Duration(milliseconds: step.delayAfterMs));
      }
    }

    if (sawWarning) {
      return CommandResult.warn(
        '매크로 완료(경고 포함). 장비 상태를 확인하세요.',
        sentCommands: sent,
      );
    }
    return CommandResult.ok('매크로 완료', sentCommands: sent);
  }
}
