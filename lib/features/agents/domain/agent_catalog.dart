import '../../../shared/models/app_models.dart';

const agentCatalog = [
  AgentDefinition(
    id: 'orchestrator',
    name: 'Orchestrator Agent',
    role: 'Plans the workflow and dispatches tasks.',
    deliverables: ['Execution plan', 'Task assignment'],
  ),
  AgentDefinition(
    id: 'pm',
    name: 'PM Agent',
    role: 'Defines PRD, scope, and user flow.',
    deliverables: ['PRD', 'Feature list', 'User flow'],
  ),
  AgentDefinition(
    id: 'system',
    name: 'System Designer Agent',
    role: 'Designs schema, RLS, and system model.',
    deliverables: ['Schema', 'Policies', 'Architecture notes'],
  ),
  AgentDefinition(
    id: 'flutter',
    name: 'Flutter Agent',
    role: 'Builds UI structure and implementation plan.',
    deliverables: ['UI map', 'Flutter code skeleton'],
  ),
  AgentDefinition(
    id: 'qa',
    name: 'QA Agent',
    role: 'Validates output quality and missing edge cases.',
    deliverables: ['QA report', 'Risk checklist'],
  ),
];
