enum ProjectHealth { onTrack, atRisk, delayed }

class Project {
  final String id;
  final String title;
  final String description;
  final String category;
  final ProjectHealth health;
  final int totalTasks;
  final int completedTasks;
  final DateTime deadline;

  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.health,
    required this.totalTasks,
    required this.completedTasks,
    required this.deadline,
  });

  double get progress => totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
  int get progressPercent => (progress * 100).round();

  static List<Project> sampleProjects = [
    Project(
      id: 'proj_1',
      title: 'Company Task Manager App',
      description: 'Internal project & milestone tracking mobile app for company engineers.',
      category: 'Mobile / Flutter',
      health: ProjectHealth.onTrack,
      totalTasks: 12,
      completedTasks: 4,
      deadline: DateTime.now().add(const Duration(days: 7)),
    ),
    Project(
      id: 'proj_2',
      title: 'Universal Mobile Starter Template',
      description: 'Offline-first React Native reference boilerplate with CI/CD and tests.',
      category: 'Foundation',
      health: ProjectHealth.onTrack,
      totalTasks: 8,
      completedTasks: 8,
      deadline: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Project(
      id: 'proj_3',
      title: 'Voice Agent Client Integration',
      description: 'Real-time voice processing and Groq API token manager.',
      category: 'AI / Mobile',
      health: ProjectHealth.atRisk,
      totalTasks: 15,
      completedTasks: 9,
      deadline: DateTime.now().add(const Duration(days: 4)),
    ),
    Project(
      id: 'proj_4',
      title: 'Q4 Infrastructure & CI/CD',
      description: 'Automated GitHub Actions linting, unit tests, and release pipelines.',
      category: 'DevOps',
      health: ProjectHealth.onTrack,
      totalTasks: 6,
      completedTasks: 5,
      deadline: DateTime.now().add(const Duration(days: 14)),
    ),
  ];
}
