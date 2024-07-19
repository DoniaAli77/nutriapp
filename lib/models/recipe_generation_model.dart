class RecipeGenerationResponse {
  final String recipe;

  RecipeGenerationResponse({
    required this.recipe,
  });

  factory RecipeGenerationResponse.fromJson(Map<String, dynamic> json) {
    return RecipeGenerationResponse(
      recipe: json['recipe'],
    );
  }
}
