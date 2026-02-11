import 'app_localizations.dart';

class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs() : super('es');

  @override
  String get profile => 'Perfil';

  @override
  String get helloAgain => '¡Hola de nuevo,';

  @override
  String get user => 'Usuario';

  @override
  String get progress => 'Progreso';
  String get personalMessage => '💝 Mensaje Personal';

  @override
  String get personalizedMessageAM =>
      'Hola :name, tu plan incluye 3 comidas principales (Desayuno, Almuerzo, Cena) y un snack en la media mañana, como prefieres.';

  @override
  String get personalizedMessagePM =>
      'Hola :name, tu plan incluye 3 comidas principales (Desayuno, Almuerzo, Cena) y un snack en la media tarde, como prefieres.';

  @override
  String get personalizedMessageDefault =>
      'Hola :name, tu plan incluye 3 comidas principales (Desayuno, Almuerzo, Cena) y un snack en la media mañana.';

  @override
  String get personalData => 'Datos Personales';

  @override
  String get selectTime => 'Seleccionar hora';

  @override
  String get useEnglish => 'Usar Inglés';

  @override
  String get checkInFewMinutes =>
      'Revisa en unos minutos desde la pantalla principal.';

  @override
  String get tellUsAboutYou => 'Cuéntanos un poco sobre ti';

  @override
  String get dataEssentialForPlan =>
      'Estos datos s°on esenciales para crear tu plan.';

  @override
  String get height => 'Estatura:';

  @override
  String get weight => 'Peso:';

  String weightKg(String kg) => '$kg kg';
  String heightCm(String cm) => '$cm cm';

  @override
  String get age => 'Edad:';

  @override
  String get country => 'País:';

  @override
  String get selectCountry => 'Selecciona un país';

  @override
  String get iIdentifyAs => 'Me identifico como:';

  @override
  String get male => 'Masculino';

  @override
  String get female => 'Femenino';

  @override
  String get saveAndContinue => 'Guardar y Continuar';

  @override
  String get dataSavedSuccess => '¡Datos guardados con éxito!';

  @override
  String get errorSavingProfile => 'Error al guardar el perfil';

  @override
  String get completeAllRequiredFields =>
      'Por favor, complete todos los campos requeridos.';

  @override
  String get heightRequired => 'La estatura es requerida.';

  @override
  String get heightBetween => 'La estatura debe estar entre 120 y 220 cm.';

  @override
  String get weightRequired => 'El peso es requerido.';

  @override
  String get weightBetween => 'El peso debe estar entre 30 y 180 kg.';

  @override
  String get ageRequired => 'La edad es requerida.';

  @override
  String get ageBetween => 'La edad debe estar entre 16 y 90 años.';

  @override
  String get selectCountryRequired => 'Por favor, selecciona un país.';

  @override
  String get selectOptionRequired => 'Por favor, selecciona una opción.';

  @override
  String ageYears(int age) => '$age años';

  @override
  String get yourProgress => 'Tu Progreso';

  @override
  String get currentStreak => 'Racha Actual';

  @override
  String get days => 'Días';

  @override
  String get yourGoal => 'Tu Objetivo';

  @override
  String get balance => 'Balance';

  @override
  String get completeMyDay => '¡Cumplí mi día!';

  @override
  String get alreadyCompletedToday => '¡Ya cumpliste hoy!';

  @override
  String congratsStreakNow(int streak) =>
      '¡Felicidades! Tu racha ahora es de $streak días.';

  @override
  String get errorLoadingProgress => 'Error al cargar tu progreso';

  @override
  String get day => 'Día';

  @override
  String get milestone => 'Hito';

  @override
  String get notDefined => 'No definido';

  @override
  String get meters => 'm';

  @override
  String get pounds => 'lbs';

  @override
  String get years => 'años';

  // ⭐ ChatScreen translations
  @override
  String get chatTitle => 'Frutia';

  @override
  String get messagesRemaining => 'mensajes restantes';

  @override
  String get saveChat => 'Guardar';

  @override
  String get saveShowcaseTitle => 'Guardar Chat';

  @override
  String get saveShowcaseDesc =>
      'Usa este botón para guardar la conversación, si no la guardas se perderá.';

  @override
  String get micShowcaseTitle => 'Entrada de Voz';

  @override
  String get micShowcaseDesc =>
      'Si no quieres escribir, puedes tocar aqui para grabar tu mensaje o detener la grabación.';

  @override
  String get voiceChatShowcaseTitle => 'Chat de Voz Avanzado';

  @override
  String get voiceChatShowcaseDesc =>
      'Inicia una conversación de voz fluida con la IA.';

  @override
  String get messageLimit => 'Límite de mensajes alcanzado';

  @override
  String get messageLimitDesc =>
      'Hazte premium para chatear con Frutia sin límites y acceder a todas las funciones.';

  @override
  String get viewPremiumPlans => 'Ver Planes Premium';

  @override
  String get createPlanFirst => 'Crea tu Plan Primero';

  @override
  String get needActivePlan =>
      'Necesitas un plan de alimentación activo para poder chatear con Frutia y obtener consejos personalizados.';

  @override
  String get createMyPlan => 'Crear Mi Plan';

  @override
  String get backToHome => 'Volver al inicio';

  @override
  String get typeMessage => 'Escribe tu mensaje...';

  @override
  String get stopRecording => 'Detener grabación';

  @override
  String get startRecording => 'Iniciar grabación';

  @override
  String get advancedVoiceChat => 'Chat de voz avanzado';

  @override
  String get imageAttached => 'Imagen adjunta';

  @override
  String get textCopied => 'Texto copiado';

  @override
  String get errorLoadingImage => 'Error al cargar imagen';

  @override
  String get bodyFatPercentage => '% Grasa Corporal';

  @override
  String get estimated => '(Estimado)';

  @override
  String get recommendation => 'Recomendación:';

  @override
  String get observations => 'Observaciones:';

  @override
  String get thinkingResponse => 'Pensando en tu respuesta... 🤔';

  @override
  String get analyzingPlan => 'Analizando tu plan nutricional... 📊';

  @override
  String get consultingHistory => 'Consultando tu historial del día... 📝';

  @override
  String get preparingResponse => 'Preparando una respuesta personalizada... ✨';

  @override
  String get reviewingMacros => 'Revisando tus macros restantes... 🔢';

  @override
  String get connectingAI => 'Conectando con la IA de Frutia... 🧠';

  @override
  String get calculatingRecommendations => 'Calculando recomendaciones... 💡';

  @override
  String get verifyingProgress => 'Verificando tu progreso... 📈';

  @override
  String get searchingBestAnswer => 'Buscando la mejor respuesta para ti... 🎯';

  @override
  String get processingQuery => 'Procesando tu consulta... ⚙️';

  @override
  String get almostReady => 'Casi lista tu respuesta... ⏳';

  @override
  String get noMessagesToSave => 'No hay mensajes para guardar';

  @override
  String get changeTitle => 'Cambiar título';

  @override
  String get saveConversation => 'Guardar Conversación';

  @override
  String get titleLabel => 'Título';

  @override
  String get titleHint => 'Escribe un título...';

  @override
  String get save => 'Guardar';

  @override
  String get chatSaved => 'Chat guardado correctamente';

  @override
  String get errorSavingChat => 'Error al guardar el chat';

  @override
  String get micPermissionRequired => 'Se requieren permisos de micrófono';

  @override
  String get enableMicPermission =>
      'Por favor habilita los permisos de micrófono en Configuración';

  @override
  String get speechNotAvailable =>
      'El reconocimiento de voz no está disponible';

  @override
  String get errorStartingSpeech => 'Error al iniciar';

  @override
  String get errorStoppingSpeech => 'Error al detener';

  @override
  String get errorVerifyingPlan => 'No se pudo verificar el estado de tu plan.';

  @override
  String get newConversationTitle => 'Nueva conversación';

  @override
  String get errorProcessingImage => 'Ocurrió un error al procesar la imagen.';

  @override
  String get errorAnalyzingImage =>
      'Lo siento, no pude analizar la imagen. Inténtalo de nuevo. 😥';

  @override
  String get pleaseLogin => 'Por favor, inicia sesión para continuar';

  @override
  String get errorStartingSession => 'Error al iniciar la sesión';

  @override
  String get sessionStartedError =>
      'No se pudo iniciar la sesión. Inténtalo de nuevo.';

  @override
  String get errorSendingMessage => 'Error al enviar el mensaje';

  @override
  String get errorAnalyzingImageShort => 'Error al analizar la imagen';

  String get yourNutritionalProfile => 'Tu Perfil Nutricional';
  String get bmi => 'IMC';
  String get calories => 'Calorías';

  @override
  String get termsAndConditions => 'Términos y condiciones';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get helpAndSupport => 'Ayuda y soporte';

  @override
  String get myAccount => 'Mi cuenta';

  @override
  String streakDays(int count) => '$count días';

  @override
  String get streak => 'Racha';

  @override
  String get trialRemaining => 'Prueba restante';

  @override
  String get yourWeek => 'Tu semana';

  @override
  String get completeYourDay => '¡Completa tu día!';

  @override
  String youAreOn(int count) => 'Vas por $count días. ¡Vamos!';

  @override
  String get startYourStreak => '¡Es hora de empezar tu racha!';

  @override
  String get lostStreak => '¡Oh, no! Perdiste tu racha';

  @override
  String hadDays(int count) => 'Llevabas $count días. ¡Empieza una nueva hoy!';

  @override
  String get streakInDanger => '¡Tu racha está en peligro!';

  @override
  String get lastDayToSave => 'Hoy es el último día para salvarla.';

  @override
  String get dontForgetStreak => '¡No te olvides de tu racha!';

  @override
  String get waitingForYou => 'Te está esperando. Llevas 2 días sin racha';

  @override
  String get yourRecipesToday => 'Tus recetas de hoy';

  @override
  String get createYourPlan => 'Crea tu plan';

  @override
  String get noActivePlan => '¡No tienes un plan activo!';

  @override
  String get createPersonalizedPlan =>
      'Crea un plan personalizado para alcanzar tus metas de manera efectiva.';

  @override
  String get createPlanNow => 'Crea tu plan ahora';

  @override
  String get upcomingMeal => 'Próxima comida';

  @override
  String get breakfast => 'Desayuno';

  @override
  String get lunch => 'Almuerzo';

  @override
  String get dinner => 'Cena';

  @override
  String get timeToSleep => 'Hora de dormir';

  @override
  String get breakfastStarting => 'Tu desayuno está por comenzar';

  @override
  String get lunchSoon => 'Pronto será hora de almorzar';

  @override
  String get lunchTime => '¡Es hora de almorzar!';

  @override
  String get dinnerApproaching => 'Tu cena se acerca';

  @override
  String get dinnerTime => '¡Es hora de cenar!';

  @override
  String get nextMealBreakfast => 'Tu próxima comida será el desayuno';

  @override
  String nextMeal(String meal) => 'Próxima comida: $meal';

  @override
  String get premiumMembership => 'Membresía Premium';

  @override
  String get enjoyingBenefits => 'Estás disfrutando de todos los beneficios';

  @override
  String get inTrialPeriod => 'En Período de Prueba';

  @override
  String trialDaysLeft(String days) => 'Te quedan $days de prueba gratuita';

  @override
  String get upgradeMembership => 'Actualiza tu membresía';

  @override
  String get unlockPremium => 'Desbloquea todas las funciones premium';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutConfirm => '¿Cerrar sesión?';

  @override
  String get aboutToLogout => 'Estás a punto de salir de tu cuenta.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get exit => 'Salir';

  @override
  String get affiliateCodeUsed => 'Código de afiliado usado:';

  @override
  String get somethingWentWrong => '¡Algo salió mal!';

  @override
  String get couldNotLoadProfile =>
      'No pudimos cargar tu perfil. Por favor, intenta de nuevo o contacta a soporte si el problema persiste.';

  @override
  String get retry => 'Reintentar';

  @override
  String get dayCompleted => '¡Día completado! Tu racha continúa.';

  @override
  String get termsAndConditionsTitle => 'Términos y Condiciones';

  @override
  String get termsTitle => 'Términos y Condiciones de Uso';

  @override
  String get termsIntro =>
      'Bienvenido(a) a Frutia. Al utilizar nuestra aplicación, aceptas cumplir con los siguientes términos y condiciones. Por favor, léelos cuidadosamente antes de continuar usando nuestros servicios.';

  @override
  String get termsSection1 =>
      '1. Aceptación de los Términos\nAl descargar, instalar o usar la aplicación Frutia, aceptas estos términos y condiciones en su totalidad. Si no estás de acuerdo con alguna parte, te pedimos que no utilices la aplicación.';

  @override
  String get termsSection2 =>
      '2. Uso de la Aplicación\nFrutia está diseñada para proporcionar planes de nutrición personalizados basados en tus preferencias, metas y estilo de vida. No garantizamos resultados específicos, ya que los resultados pueden variar según el usuario. Debes usar la aplicación bajo tu propia responsabilidad y consultar a un profesional de la salud antes de realizar cambios significativos en tu dieta.';

  @override
  String get termsSection3 =>
      '3. Privacidad\nTu privacidad es importante para nosotros. La información que compartas con Frutia será tratada de acuerdo con nuestra Política de Privacidad, que puedes consultar en la aplicación o en nuestro sitio web.';

  @override
  String get termsSection4 =>
      '4. Propiedad Intelectual\nTodo el contenido de la aplicación, incluyendo textos, gráficos, logotipos y software, es propiedad de Frutia o sus licenciantes y está protegido por las leyes de propiedad intelectual. No puedes copiar, modificar, distribuir o reproducir ningún contenido sin nuestro consentimiento expreso.';

  @override
  String get termsSection5 =>
      '5. Modificaciones\nNos reservamos el derecho de modificar estos términos y condiciones en cualquier momento. Te notificaremos sobre cambios significativos a través de la aplicación o por otros medios. El uso continuado de la aplicación implica la aceptación de los términos actualizados.';

  @override
  String get termsSection6 =>
      '6. Contacto\nSi tienes preguntas sobre estos términos, puedes contactarnos en soporte@frutia.com.';

  @override
  String get goBack => 'Volver';

  @override
  String get privacyPolicyTitle => 'Política de Privacidad';

  @override
  String get privacyTitle => 'Política de Privacidad';

  @override
  String get privacyIntro =>
      'En Frutia, tu privacidad es una prioridad. Esta Política de Privacidad explica cómo recopilamos, usamos, protegemos y compartimos tu información cuando utilizas nuestra aplicación. Al usar Frutia, aceptas las prácticas descritas a continuación.';

  @override
  String get privacySection1 =>
      '1. Información que Recopilamos\nRecopilamos información que nos proporcionas directamente, como tu nombre, correo electrónico, preferencias alimenticias, metas de salud y datos sobre tu rutina. También podemos recopilar datos generados por tu uso de la aplicación, como interacciones con el sistema y preferencias de configuración.';

  @override
  String get privacySection2 =>
      '2. Uso de la Información\nUtilizamos tu información para personalizar tus planes de nutrición, mejorar la funcionalidad de la aplicación y ofrecerte una experiencia adaptada a tus necesidades. También podemos usar datos anonimizados para análisis y mejoras del servicio.';

  @override
  String get privacySection3 =>
      '3. Compartir Información\nNo vendemos ni compartimos tu información personal con terceros, salvo en casos requeridos por la ley o para proteger los derechos de Frutia. Podemos compartir datos anonimizados con socios para fines de investigación o mejora del servicio.';

  @override
  String get privacySection4 =>
      '4. Seguridad de los Datos\nImplementamos medidas de seguridad técnicas y organizativas para proteger tu información. Sin embargo, ningún sistema es completamente infalible, por lo que te recomendamos tomar precauciones adicionales, como usar contraseñas seguras.';

  @override
  String get privacySection5 =>
      '5. Tus Derechos\nPuedes acceder, corregir o eliminar tu información personal en cualquier momento desde la configuración de la aplicación. Si tienes dudas o necesitas asistencia, contáctanos en soporte@frutia.com.';

  @override
  String get privacySection6 =>
      '6. Cambios en esta Política\nNos reservamos el derecho de actualizar esta política. Te notificaremos sobre cambios significativos a través de la aplicación o por correo electrónico. El uso continuado de Frutia implica la aceptación de la política actualizada.';

  @override
  String get helpAndSupportTitle => 'Ayuda y Soporte';

  @override
  String get helpTitle => 'Ayuda y Soporte';

  @override
  String get helpIntro =>
      'En Frutia, estamos aquí para ayudarte. Si tienes alguna duda, problema o simplemente quieres saber más sobre cómo sacarle el máximo provecho a la aplicación, ¡estamos a tu disposición!';

  @override
  String get helpSection1 =>
      '1. Preguntas Frecuentes (FAQs)\nConsulta las preguntas más comunes sobre el uso de Frutia. Aquí encontrarás información sobre cómo personalizar tu plan, ajustar tus preferencias o gestionar tu cuenta.';

  @override
  String get viewFAQs => 'Ver Preguntas Frecuentes';

  @override
  String get helpSection2 =>
      '2. Contáctanos\nSi necesitas ayuda personalizada, nuestro equipo de soporte está listo para ayudarte. Escríbenos y te responderemos lo antes posible.';

  @override
  String get contactEmail => 'Correo: soporte@frutia.com';

  @override
  String get helpSection3 =>
      '3. Comunidad Frutia\nÚnete a nuestra comunidad en redes sociales para compartir experiencias, recetas y consejos con otros usuarios. Síguenos en nuestras plataformas oficiales.';

  @override
  String get helpSection4 =>
      '4. Actualizaciones y Feedback\n¿Tienes alguna sugerencia para mejorar Frutia? Nos encantaría escucharte. Envía tus comentarios a través del formulario en la aplicación o por correo.';

  @override
  String get welcomeToFrutia => 'Bienvenido a Frutia';

  @override
  String get enterCredentials => 'Ingresa tus credenciales para continuar';

  @override
  String get email => 'Correo';

  @override
  String get password => 'Contraseña';

  @override
  String get rememberMe => 'Recordarme';

  @override
  String get forgotPassword => 'Olvidé mi contraseña';

  @override
  String get signIn => 'Entrar';

  @override
  String get signInWithGoogle => 'Unirse con Google';

  @override
  String get createAccount => 'Crea tu cuenta';

  @override
  String get notificationsDisabled => 'Notificaciones desactivadas';

  @override
  String get unexpectedError =>
      'Ocurrió un error inesperado. Inténtalo de nuevo.';

  @override
  String get completeAllFields => 'Por favor complete todos los campos';

  @override
  String get invalidEmail => 'Correo electrónico inválido';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get googleSignInError => 'Error al iniciar sesión con Google';

  @override
  String get registration => 'Registro';

  @override
  String get welcomeCompleteRegistration => 'Bienvenido, Completa tu registro.';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get emailAddress => 'Correo electrónico';

  @override
  String get phoneNumber => 'Número de teléfono';

  @override
  String get confirmPassword => 'Confirmar Contraseña';

  @override
  String get affiliateCodeOptional => 'Código de afiliado (Opcional)';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get protein => 'Proteína';

  @override
  String get nameOnlyLetters => 'El nombre solo debe contener letras';

  @override
  String get pleaseEnterNumber => 'Por favor ingresa un número';

  @override
  String get invalidPhoneNumber =>
      'El número de teléfono no es válido para el país seleccionado.';

  @override
  String get skip => 'OMITIR';

  @override
  String welcomeMessage(String name) => '¡Bienvenido, $name! Registro exitoso.';

  @override
  String get personalizedNutrition => 'Nutrición 100% personalizada';

  @override
  String get plansAdaptedToYou => 'Planes adaptados a tus objetivos y gustos';

  @override
  String get aiCoachPersonalTracking => 'Coach de IA con seguimiento personal';

  @override
  String get adaptableToYourStyle => 'Adaptable a tu estilo y presupuesto';

  @override
  String get fastAndMadeForYou => 'Rápido y hecho solo para ti';

  @override
  String get whatPlanWeOffer => '¿QUÉ PLAN OFRECEMOS?';

  @override
  String get frutiaPlan => 'Plan Frutia:';

  @override
  String get personalizedVirtualNutritionist =>
      'Nutricionista virtual personalizado';

  @override
  String get trackingFoodHabitsWeight =>
      'Seguimiento de alimentos, hábitos y peso';

  @override
  String get remember => 'Recuerda';

  @override
  String get genericPlansDontWork =>
      '❌ Los planes genéricos no funcionan. Cada cuerpo es distinto.';

  @override
  String get noMagicSolutions =>
      '🚫 No existen soluciones mágicas ni "tés milagrosos".';

  @override
  String get budgetMatters =>
      '💸 Tu presupuesto importa, y debería ser parte del plan.';

  @override
  String get firstStepToChange =>
      'Este es el primer paso hacia el cambio que mereces';

  @override
  String get aboutUs => 'Nosotros';

  @override
  String get ourStory => 'Nuestra Historia';

  @override
  String get ourStoryParagraph1 =>
      'Creamos esta app con una idea clara: la nutrición no debería sentirse como una carga, ni depender de planes genéricos que no se adaptan a tu vida. Por eso combinamos ciencia, tecnología e inteligencia artificial para ofrecerte un acompañamiento real, sin fórmulas mágicas, sin promesas vacías, y sin complicarte el día a día.';

  @override
  String get streakReminderDescription =>
      'Toca aquí para marcar tu día como completado y mantener o iniciar tu racha. ¡Hazlo diario!';

  @override
  String get weekCalendarDescription =>
      'Aquí puedes ver los días que has completado tu plan y el estado de tu racha diaria.';

  @override
  String get myPlanForToday => 'Mi Plan de Hoy';

  @override
  String get yourDaySummary => 'Resumen de tu Día';

  @override
  String get viewHistory => 'Ver Historial';

  @override
  String get downloadPDF => 'Descargar PDF';

  @override
  String get carbs => 'Carbs';

  @override
  String get fats => 'Grasas';

  @override
  String get accompanySaladFree => 'Acompañar con Ensalada LIBRE';

  @override
  String selectAtLeastOneOption(String meal) =>
      'Selecciona AL MENOS una opción para registrar tu $meal';

  @override
  String canAddMoreOptions(int selected, int total) =>
      'Puedes agregar más opciones o confirmar ahora ($selected/$total)';

  @override
  String completeMealConfirm(String meal) =>
      '¡Comida completa! Puedes confirmar tu $meal';

  @override
  String recipeIdeasFor(String meal) => 'Ideas de Recetas para $meal';

  @override
  String get useIngredientsAbove =>
      'Usa los ingredientes de arriba para crear estas deliciosas recetas';

  @override
  String mealCompleted(String meal) => '$meal Completado ✨';

  @override
  String get comeBackTomorrow => 'Regresa mañana para un nuevo día';

  @override
  String registeringMeal(String meal) => 'Registrando $meal...';

  @override
  String confirmMeal(String meal, int calories) =>
      '¡Confirmar $meal! ($calories kcal)';

  @override
  String confirmPartialMeal(String meal, int calories) =>
      '¡Confirmar $meal Parcial! ($calories kcal)';

  @override
  String mealRegisteredSuccess(String meal) => '$meal registrado con éxito.';

  @override
  String errorRegistering(String error) => 'Error al registrar: $error';

  @override
  String errorLoadingData(String error) => 'Error al cargar tus datos: $error';

  @override
  String get noMealPlan => 'No se encontró un plan de alimentación.';

  @override
  String get myPlan => 'Mi Plan';

  @override
  String get recipes => 'Recetas';

  @override
  String get shopping => 'Compras';

  @override
  String get modifications => 'Modificaciones';

  @override
  String get myPlanDescription =>
      'Aquí podrás ver y gestionar tu plan de alimentación personalizado.';

  @override
  String get recipesDescription =>
      'Explora deliciosas recetas adaptadas a tus necesidades y preferencias.';

  @override
  String get shoppingDescription =>
      'Organiza tus listas de compras para una experiencia sin estrés.';

  @override
  String get modificationsDescription =>
      'Solicita cambios o ajustes en tu plan o recetas directamente aquí.';

  @override
  String get yourChatsWithFrutia => 'Tus chats con Frutia';
  @override
  String get reload => 'Recargar';
  @override
  String get newConversation => 'Nueva Conversación';
  @override
  String get searchConversations => 'Buscar conversaciones...';
  @override
  String get conversationDeleted => 'Conversación eliminada';
  @override
  String get errorLoadingConversations => 'Error al cargar las conversaciones';
  @override
  String get deleteConversation => 'Eliminar Conversación';
  @override
  String get sureDeleteConversation =>
      '¿Estás seguro de que quieres eliminar esta conversación?';
  @override
  String get delete => 'Eliminar';
  @override
  String get normalChat => 'Chat Normal';
  @override
  String get voiceChat => 'Chat de Voz';
  @override
  String get noConversationsYet => '¡No hay conversaciones aún!';
  @override
  String get startNewConversation =>
      'Empieza una nueva conversación con Frutia, ya sea por texto o voz.';
  @override
  String todayAt(String time) => 'Hoy a las $time';
  @override
  String yesterdayAt(String time) => 'Ayer a las $time';

// ⭐ QUESTIONNAIRE TRANSLATIONS
  @override
  String get aboutYou => 'Sobre ti 👤';

  @override
  String get doYouHaveMedicalCondition => '¿Tienes alguna condición médica? 🩺';

  @override
  String get specifySuchAs => 'Específica (ej. diabetes)';

  @override
  String get mainGoal => 'Objetivo Principal';

  @override
  String get loseBodyFat => '🔥 Bajar grasa';

  @override
  String get gainMuscle => '💪 Aumentar músculo';

  @override
  String get eatHealthier => '🥗 Comer más saludable';

  @override
  String get improvePerformance => '📈 Mejorar rendimiento';

  @override
  String get yourRoutine => 'Tu Rutina 🏃‍♂️';

  @override
  String get whatSportsDoYouPractice =>
      '¿Qué deporte practicas? (puedes seleccionar varios) 🏀';

  @override
  String get selectMultiple => 'puedes seleccionar varios';

  @override
  String get whichMostLikeYourWeek => '¿Cuál se parece más a tu semana?';

// ⭐ SPORT SELECTION TRANSLATIONS
  @override
  String get gym => '💪 Gym';

  @override
  String get soccer => '⚽ Fútbol';

  @override
  String get running => '🏃 Running';

  @override
  String get tennis => '🎾 Tenis';

  @override
  String get other => '✏️ Otro';

  @override
  String get none => '❌ Ninguno';

  @override
  String get specifyYourSport => '✏️ Especifica tu deporte';

  @override
  String get noMoveNoTrain => 'No me muevo y no entreno (Ej: oficina + sofá)';

  @override
  String get officeTrainOneTwoTimes =>
      'Oficina + entreno 1-2 veces (Ej: gym lunes y jueves)';

  @override
  String get officeTrainThreeFourTimes =>
      'Oficina + entreno 3-4 veces (Ej: gym lunes a jueves)';

  @override
  String get officeTrainFiveSixTimes =>
      'Oficina + entreno 5-6 veces (Ej: gym casi todos los días)';

  @override
  String get activeWorkTrainOneTwoTimes =>
      'Trabajo activo + entreno 1-2 veces (Ej: mozo + gym 2 días)';

  @override
  String get activeWorkTrainThreeFourTimes =>
      'Trabajo activo + entreno 3-4 veces (Ej: mozo + gym 4 días)';

  @override
  String get veryPhysicalWorkTrainFiveSixTimes =>
      'Trabajo muy físico + entreno 5-6 veces (Ej: construcción + gym diario)';

  @override
  String get yourMealStructure => 'Tu Estructura de Comidas 🍽️';

  @override
  String get whenPreferSnack => '¿Cuándo prefieres tu snack? 🍎';

  @override
  String get planIncludesOneSnack =>
      'Tu plan incluirá SOLO UN snack. Elige cuándo lo prefieres:';

  @override
  String get midMorningSnackAM => 'Media mañana (Snack AM)';

  @override
  String get betweenBreakfastLunch => 'Entre desayuno y almuerzo';

  @override
  String get midAfternoonSnackPM => 'Media tarde (Snack PM)';

  @override
  String get betweenLunchDinner => 'Entre almuerzo y cena';

  @override
  String get whatTimeDoYouUsuallyEat => '¿A qué hora sueles comer? (opcional)';

  @override
  String get optional => 'opcional';

  @override
  String get howOftenEatOut => '¿Con qué frecuencia comes fuera de casa? 🍔';

  @override
  String get almostEveryDay => '🍔 Casi todos los días';

  @override
  String get sometimesTwoToFourTimesWeek =>
      '🍎 A veces (2 a 4 veces por semana)';

  @override
  String get rarelyOnceWeekOrLess => '🥗 Rara vez (1 vez por semana o menos)';

  @override
  String get never => '🚫 Nunca';

  @override
  String get tasteAllergiesDietaryStyle =>
      'Gustos, alergias y estilo alimentario 🥗';

  @override
  String get whatFoodsDontYouLike => '¿Qué alimentos NO te gusta?';

  @override
  String get exampleBroccoliLiver => 'Ej: brócoli, hígado, etc.';

  @override
  String get doYouHaveFoodAllergies => '¿Tienes alguna alergia alimentaria? 🚨';

  @override
  String get yesIHaveAllergies => 'Sí, tengo alergias 😷';

  @override
  String get noNone => 'No, ninguna ✅';

  @override
  String get specifyHere => 'Especifícalas aquí';

  @override
  String get doYouFollowDietaryStyle => '¿Sigues algún estilo de alimentación?';

  @override
  String get omnivore => '🍖 Omnívoro';

  @override
  String get vegetarian => '🥕 Vegetariano';

  @override
  String get vegan => '🌱 Vegano';

  @override
  String get keto => '🥚 Keto';

  @override
  String get specifyYourStyle => '✏️ Especifica tu estilo';

  @override
  String get whatBudgetForWeeklyFood =>
      '¿Con qué tipo de presupuesto cuentas para tu alimentación semanal? 💰';

  @override
  String get lowOnlyBasics =>
      '💸 Bajo - Solo lo básico (Ej: arroz, huevo, lentejas)';

  @override
  String get highNoRestrictions =>
      '💳 Alto - Sin restricciones (Ej: salmón, proteína, superfoods)';

  @override
  String get foodsYouLikemost => 'Alimentos que más te gustan 🍴';

  @override
  String get selectFavoritesToAppearMore =>
      'Selecciona tus favoritos para que aparezcan más en tu plan';

  @override
  String get proteins => 'Proteínas';

  @override
  String get chooseAtLeastThree => 'Elige al menos 3';

  @override
  String get carbohydrates => 'Carbohidratos';

  @override
  String get chooseAtLeastTwo => 'Elige al menos 2';

  @override
  String get fruitsForSnacks => 'Frutas (para Snacks)';

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get emotionalPersonalization =>
      'Personalización emocional (opcional) 🌟';

  @override
  String get whatHardestMaintainInPlan =>
      '¿Qué es lo que más te cuesta mantener en un plan de alimentación?';

  @override
  String get stayConsistent => 'Mantenerme constante 🔄';

  @override
  String get knowWhatToEatWhenDontHavePlan =>
      'Saber qué comer cuando no tengo lo del plan 🤔';

  @override
  String get eatHealthyOutsideHome => 'Comer saludable fuera de casa 🍽️';

  @override
  String get controlCravings => 'Controlar los antojos 🍫';

  @override
  String get prepareMeals => 'Preparar la comida 🧑‍🍳';

  @override
  String get specify => 'Especifica';

  @override
  String get whatMotivatesYouMostToFollowPlan =>
      '¿Qué es lo que más te motiva a seguir un plan de alimentación?';

  @override
  String get seeQuickResults => 'Ver resultados rápidos ⚡';

  @override
  String get feelBetterPhysically =>
      'Sentirme mejor físicamente (energía, digestión, menos pesadez) 💪';

  @override
  String get proveToMyselfICanDoIt => 'Demostrarme que puedo lograrlo 💯';

  @override
  String get improveHealthLongTerm => 'Mejorar mi salud a largo plazo 🏥';

  @override
  String get notClearYet => 'Aún no lo tengo claro ❓';

  @override
  String get yourPreferences => 'Tus Preferencias 🌟';

  @override
  String get howPreferICommunicateWithYou =>
      '¿Cómo prefieres que me comunique contigo?';

  @override
  String get motivational =>
      'Motivadora (que te empuje a dar más cuando lo necesites) 🏋️';

  @override
  String get close => 'Cercana (como un amigo que te acompaña sin presión) 😊';

  @override
  String get direct => 'Directa (clara, sin vueltas ni frases suaves) 🤗';

  @override
  String get whateverWorksForYou => 'Como te salga a ti, yo me adapto 🔄';

  @override
  String get whatWouldYouLikeToCallYou => '¿Cómo te gustaría que te llame?';

  @override
  String get yourNameOrNickname => 'Tu nombre o apodo';

  @override
  String get back => 'Atrás';

  @override
  String get continue_ => 'Continuar';

  @override
  String get saveChanges => 'Guardar Cambios';

  @override
  String get finish => 'Finalizar';

  @override
  String get readyForPersonalizedPlan =>
      '¡Listo para un plan hecho solo para ti! 🌟';

  @override
  String get modifyYourPersonalizedPlan =>
      '¡Modifica tu plan personalizado! 🌟';

  @override
  String get answerQuestionsForIdealPlan =>
      'Responde estas preguntas para armar tu plan ideal según tu vida real. 📋';

  @override
  String get updateAnswersToAdjust =>
      'Actualiza tus respuestas para ajustar tu plan a tus nuevas necesidades. 📋';

  @override
  String get swipeOrPressContinue => "Desliza o presiona 'Continuar' ➡️";

  @override
  String get selectMainGoal => 'Selecciona un objetivo principal.';

  @override
  String get specifyMedicalCondition => 'Específica tu condición médica.';

  @override
  String get selectAtLeastOneSport => 'Selecciona al menos un deporte.';

  @override
  String get selectWhenPreferSnack => 'Selecciona cuándo prefieres tu snack.';

  @override
  String get selectHowOftenEatOut =>
      'Selecciona con qué frecuencia comes fuera de casa.';

  @override
  String get selectDietaryStyle => 'Selecciona un estilo de alimentación.';

  @override
  String get specifyFoodAllergies => 'Específica tus alergias alimentarias.';

  @override
  String get selectWeeklyBudget => 'Selecciona tu presupuesto semanal.';

  @override
  String get selectAtLeastOneFavoriteFruit =>
      'Selecciona al menos una fruta favorita.';

  @override
  String get selectCommunicationStyle =>
      'Selecciona un estilo de comunicación.';

  @override
  String get selectAtLeastOneDifficulty =>
      'Selecciona al menos una dificultad en la dieta.';

  @override
  String get specifyOtherDifficulty =>
      'Por favor, especifica tu otra dificultad alimentaria.';

  @override
  String get selectAtLeastOneMotivation =>
      'Selecciona al menos una motivación para tu dieta.';

  @override
  String get generatingPlan => 'Generando tu plan...';

  @override
  String get updatingPlan => 'Actualizando tu plan...';

  @override
  String get pleaseWait => 'Por favor espera';

  @override
  String get planTakingLonger =>
      'Tu plan está tardando más de lo esperado. Revisa en unos minutos desde la pantalla principal.';

  @override
  String errorGeneratingPlan(String error) =>
      'Error al generar tu plan: $error';

  @override
  String errorUpdatingPlan(String error) =>
      'Error al actualizar tu plan: $error';

  @override
  String get morningSnack => 'media mañana';

  @override
  String get afternoonSnack => 'media tarde';

  @override
  String get importantSection =>
      'Esta es una sección importante de la aplicación.';

  @override
  String get ourStoryParagraph2 =>
      'Cada cuerpo es distinto, y creemos que tu alimentación debe respetarlo. Por eso, nuestro sistema se adapta a tus metas, tus gustos, tu rutina y hasta tu presupuesto. No importa si entrenas en el gimnasio, juegas fútbol los domingos o simplemente quieres comer mejor sin gastar de más: tu plan es tuyo y evoluciona contigo.';

  @override
  String get ourStoryParagraph3 =>
      'Nos mueve la idea de que la tecnología puede humanizarse. Por eso nuestra IA, Frutia, no es solo un robot que te lanza datos. Puedes decidir cómo quieres que te trate: motivadora, relajada o directa. Como si tuvieras un nutricionista virtual que sí te entiende.';

  @override
  String get ourStoryParagraph4 =>
      'Somos un equipo de nutricionistas, desarrolladores, diseñadores y soñadores, comprometidos con una nutrición accesible, realista y personalizada. Y lo más importante: hecha para durar.';

  @override
  String get youWontBeAlone => '🌟 Y no estarás solo en el camino';

  @override
  String get frutiaAccompaniesYou => '🍓 Frutia te acompaña en cada paso';

  @override
  String get foodShouldPlease => '🍽️ Tu comida debe gustarte, no estresarte.';

  @override
  String get weAreHereForYou =>
      '🤝 Estamos acá para darte un plan real, inteligente y hecho para ti.';

  @override
  String get recipesAccordingBudget => 'Recetas según tu presupuesto';

  @override
  String get savedConversationHistory => 'Historial de conversaciones guardado';

  @override
  String errorCompletingDay(String error) =>
      'Error al completar el día: $error';
  @override
  String get updatingYourPlan => 'Actualizando tu plan personalizado...';

  @override
  String get generatingYourPlan => 'Generando tu plan personalizado...';

  @override
  String get processTakesTime =>
      'El proceso puede tomar 4-6 minutos aproximadamente.';

  @override
  String get dontCloseApp => 'Por favor no cierres la aplicación';

  @override
  String get processingRequest => '⏳ Procesando tu solicitud...';

  // LoadingMessagesWidget
  @override
  String get analyzingResponses => 'Analizando tus respuestas...';

  @override
  String get creatingUniquePlan => 'Creando un plan único para ti...';

  @override
  String get frutiaAccompaniesYouLoading =>
      'Frutia está aquí para acompañarte.';

  @override
  String get almostPerfectPlan => 'Ya casi queda tu plan perfecto.';

  @override
  String get frutiaKnowsNeeds =>
      'Frutia sabe lo que necesitas en todo momento.';

  @override
  String get usersTrustUs => 'Más de mil usuarios confían en nosotros.';

  @override
  String get selectingBestRecipes =>
      'Estamos seleccionando las mejores recetas...';

  @override
  String get prepareForPositiveChange => '¡Prepárate para un cambio positivo!';

  @override
  String get calculatingMacros => 'Calculando tus macros y calorías...';

  @override
  String get adjustingPortions => 'Ajustando las porciones a tu medida.';

  @override
  String get filteringRecipes =>
      'Filtrando recetas según tus gustos y alergias...';

  @override
  String get aiWorkingForYou =>
      'Nuestra inteligencia artificial trabaja para ti.';

  @override
  String get investingInHealth => 'Estás invirtiendo en tu salud. ¡Bien hecho!';

  @override
  String get structuringMeals => 'Estructurando tus comidas para el éxito.';

  @override
  String get consistencyIsKey =>
      'La constancia es la clave, y estamos para ayudarte.';

  @override
  String get compilingShoppingList =>
      'Compiling tu lista de compras inteligente...';

  @override
  String get eatingHealthyPossible => 'Comer rico y saludable es posible.';

  @override
  String get imagineEnergy => 'Imagina la energía que tendrás.';

  @override
  String get journeyBeginsNow =>
      'Tu viaje hacia una mejor versión de ti comienza ahora.';

  @override
  String get wellnessSeriously => 'Nos tomamos tu bienestar muy en serio.';

  @override
  String get smallStepGreatLeap =>
      'Un pequeño paso para ti, un gran salto para tu salud.';

  @override
  String get patienceSecretIngredient =>
      'La paciencia es un ingrediente secreto.';

  @override
  String get optimizingBudget => 'Optimizando el plan para tu presupuesto.';

  // PlanSummaryScreen
  @override
  String planSummaryTitle(String clientName) => 'Plan de $clientName';

  @override
  String get personalMessageTitle => 'Mensaje Personal';

  @override
  String get nutritionalProfileTitle => 'Tu Perfil Nutricional';

  @override
  String get ageLabel => 'Edad';

  @override
  String get weightLabel => 'Peso';

  @override
  String get heightLabel => 'Estatura';

  @override
  String get foodExchangesTitle => 'Tus Intercambios de Alimentos';

  @override
  String get foodExchangesSubtitle =>
      'Puedes intercambiar cualquier alimento del mismo grupo por otro. ¡Flexibilidad total!';

  @override
  String get mealTimeLabel => 'Horario';

  @override
  String get tapToViewExchanges => 'Toca para ver opciones de intercambio';

  @override
  String get tipsForMeal => '💡 Consejos para esta comida:';

  @override
  String get suggestedRecipesTitle => 'Recetas Sugeridas';

  @override
  String get suggestedRecipesSubtitle =>
      'Ideas de cómo preparar tus alimentos de forma deliciosa';

  @override
  String get recipeFor => 'Para';

  @override
  String get instructionsTitle => 'Instrucciones:';

  @override
  String get goalAlignmentTitle => '🎯 Alineación con tu objetivo:';

  @override
  String get sportsSupportTitle => '🏃 Apoyo deportivo:';

  @override
  String get readyToStartButton => '¡Listo para empezar!';

  @override
  String get backButton => 'Volver';

  // SuccessScreen
  @override
  String get planCreatedTitle => '¡Tu plan alimenticio ha sido creado! 🎉';

  @override
  String get planCreatedSubtitle =>
      'Estás listo para empezar tu viaje hacia una vida más saludable.';

  @override
  String get startNowButton => 'Comenzar ahora';

  // HistoryScreen
  @override
  String get historyScreenTitle => 'Historial de Comidas';

  @override
  String get historyErrorLoading => 'Error al cargar el historial: ';

  @override
  String get historyNoRecords => 'Aún no tienes registros';

  @override
  String get historyYouSelected => 'Seleccionaste:';

  // ProfessionalMiPlanDiarioScreen (Pantalla1)
  @override
  String get userDefault => 'Usuario';

  @override
  String get dataLoadError => 'Error al cargar tus datos: ';

  @override
  String get noDataForPDF =>
      'No hay datos del plan o perfil para generar el PDF.';

  @override
  String get pdfGenError => 'Error al generar PDF: ';

  @override
  String pdfWelcome(String name) =>
      '¡Bienvenido a tu Plan Personalizado, $name!';

  @override
  String get pdfHowToUse => '¿CÓMO SEGUIR TU PLAN CORRECTAMENTE?';

  @override
  String get pdfSelectOneOption => 'SELECCIONA SOLO UNA OPCIÓN POR GRUPO';

  @override
  String get pdfFoodGroups =>
      'Proteínas: Elige UNA opción\nCarbohidratos: Elige UNA opción\nGrasas: Elige UNA opción';

  @override
  String get pdfImportantWarning =>
      'IMPORTANTE: NO selecciones todas las opciones. Solo UNA de cada grupo por comida.';

  @override
  String get pdfUseAppControl => 'USA LA APP PARA CONTROLAR TUS MACROS';

  @override
  String get pdfAppHelps => 'La aplicación FRUTIA te ayudará a:';

  @override
  String get pdfAppFeature1 => 'Seleccionar tus alimentos cada día';

  @override
  String get pdfAppFeature2 =>
      'Ver en tiempo real tus macronutrientes acumulados';

  @override
  String get pdfAppFeature3 => 'Advertirte ANTES de exceder tus límites';

  @override
  String get pdfAppFeature4 => 'Ajustar tu plan según tus preferencias diarias';

  @override
  String get pdfTip =>
      'TIP: No todos los alimentos tienen el mismo aporte calórico. Por eso es crucial que uses la app para ir seleccionando lo que consumes.';

  @override
  String get pdfLearnToManipulate => 'APRENDE A MANIPULAR TU DIETA';

  @override
  String get pdfFlexiblePlan => 'Tu plan es FLEXIBLE. Puedes:';

  @override
  String get pdfFlexibility1 => 'Comer más en el desayuno y menos en la cena';

  @override
  String get pdfFlexibility2 => 'Distribuir tus macros como prefieras';

  @override
  String get pdfFlexibility3 =>
      'Variar tus alimentos cada día para no aburrirte';

  @override
  String get pdfFlexibility4 =>
      'Ajustar porciones según tu hambre (sin exceder macros)';

  @override
  String get pdfObjective =>
      'OBJETIVO: Que aprendas a medir tu plan y evitar excesos. La variedad de alimentos te ayudará a no saturarte.';

  @override
  String get pdfFrutiaChatTitle => 'FRUTIA CHAT: Tu nuevo coach personal';

  @override
  String get pdfFrutiaChatDesc =>
      '¿Tienes dudas sobre tu plan? FRUTIA Chat es tu nuevo coach personal que simula ser tu nutricionista personal.';

  @override
  String get pdfAskAbout => 'Pregúntale sobre:';

  @override
  String get pdfAsk1 => 'Dudas sobre tu plan alimenticio';

  @override
  String get pdfAsk2 => 'Sustituciones de alimentos';

  @override
  String get pdfAsk3 => 'Recetas con los ingredientes de tu plan';

  @override
  String get pdfAsk4 => 'Consejos para tu progreso físico';

  @override
  String get pdfAsk5 => 'Cómo preparar cada alimento';

  @override
  String get pdfAsk6 => 'Cualquier duda nutricional';

  @override
  String get pdfAvailable247 =>
      'Disponible 24/7 dentro de la aplicación FRUTIA';

  @override
  String get attentionTitle => '¡Atención!';

  @override
  String get willExceedMacros => 'Excederás tus macros:';

  @override
  String exceedWarningMessage(String food, String macro, String excess) =>
      'Si seleccionas "$food", excederás $macro: +$excess';

  @override
  String get adjustmentSuggestion => '💡 Sugerencia de Ajuste';

  @override
  String get originalPortion => 'Porción Original';

  @override
  String get adjustedPortion => 'Porción Ajustada';

  @override
  String reducePortionMessage(String percent, String grams) =>
      'Reduce $percent% la porción (aproximadamente $grams menos)';

  @override
  String get customAdviceTitle => '💡 Consejo Personalizado';

  @override
  String get askFrutiaChat => 'Pregunta a Frutia Chat:';

  @override
  String get askFrutiaChatExample =>
      '"Ya comí [X], ¿puedo comer esto sin excederme?"';

  @override
  String get selectAnyway => 'Seleccionar de todas formas';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get lowBudgetWarning =>
      '💰 Este ítem es de presupuesto alto, pero tu plan es económico';

  @override
  String get alreadySelectedEgg =>
      '🥚 Ya seleccionaste huevos en otra comida. Máximo 1 vez al día';

  // Additional PDF Keys
  @override
  String get pdfGoldRule => '!';

  @override
  String get pdfGoldRuleTitle => '¡REGLA DE ORO!';

  @override
  String get pdfGoldRuleDesc =>
      'De cada comida, escoge solo UNA opción del grupo de Proteínas, UNA de Carbohidratos y UNA de Grasas para cumplir tus macros.';

  @override
  String get pdfGoldRuleWarning =>
      'Si seleccionas más de una opción por grupo, excederás tus calorías y NO alcanzarás tu objetivo.';

  @override
  String get pdfMealTableComponent => 'Componente';

  @override
  String get pdfMealTableOption => 'Opción de Alimento';

  @override
  String get pdfMealTablePortion => 'Porción Sugerida';

  @override
  String get pdfMealCalories => 'Calorías';

  @override
  String get wholeEgg => 'Huevo entero';

  @override
  String get eggWhitesWholeEgg => 'Claras + Huevo entero';

  @override
  String get cannedTuna => 'Atún en lata';

  @override
  String get chickenThigh => 'Muslo de pollo';

  @override
  String get groundBeef => 'Carne molida';

  @override
  String get greekYogurt => 'Yogur griego';

  @override
  String get broccoli => 'Brócoli';
  @override
  String get cauliflower => 'Coliflor';
  @override
  String get spinach => 'Espinacas';
  @override
  String get lettuce => 'Lechuga';
  @override
  String get zucchini => 'Calabacín';
  @override
  String get whiteRice => 'Arroz blanco';
  @override
  String get potato => 'Papa';
  @override
  String get traditionalOats => 'Avena tradicional';
  @override
  String get cornTortillas => 'Tortillas de maíz';
  @override
  String get basicNoodlesPasta => 'Fideos básicos';
  @override
  String get beans => 'Frijoles';
  @override
  String get sweetPotato => 'Camote';
  @override
  String get riceCrackers => 'Galletas de arroz';
  @override
  String get creamOfRice => 'Crema de arroz';
  @override
  String get quinoa => 'Quinua';
  @override
  String get organicOats => 'Avena orgánica';
  @override
  String get artisanWholeWheatBread => 'Pan integral artesanal';

  @override
  String get strawberries => 'Fresas';
  @override
  String get blueberries => 'Arándanos';
  @override
  String get blackberries => 'Moras';
  @override
  String get banana => 'Plátano';
  @override
  String get apple => 'Manzana';
  @override
  String get mango => 'Mango';
  @override
  String get watermelon => 'Sandía';
  @override
  String get pear => 'Pera';

  @override
  String get tofu => 'Tofu';
  @override
  String get tempeh => 'Tempeh';
  @override
  String get seitan => 'Seitán';
  @override
  String get lentils => 'Lentejas';
  @override
  String get chickpeas => 'Garbanzos';
  @override
  String get plantProteinPowder => 'Proteína vegetal en polvo';
  @override
  String get freshCheese => 'Queso fresco';
  @override
  String get cottageCheese => 'Queso cottage';
  @override
  String get panelaCheese => 'Queso panela';
  @override
  String get ricotta => 'Ricotta';
  @override
  String get chickenThighWithSkin => 'Muslo de pollo con piel';
  @override
  String get groundBeef8020 => 'Carne molida 80/20';
  @override
  String get salmon => 'Salmón';
  @override
  String get ribeye => 'Ribeye';
  @override
  String get duckBreast => 'Pechuga de pato';
  @override
  String get agedCheese => 'Queso añejo';
  @override
  String get chickenBreastOrThigh => 'Pechuga o muslo de pollo';
  @override
  String get leanBeef => 'Carne magra de res';
  @override
  String get whiteFish => 'Pescado blanco';
  @override
  String get chickenBreast => 'Pechuga de pollo';
  @override
  String get freshSalmon => 'Salmón fresco';
  @override
  String get turkeyBreast => 'Pechuga de pavo';
  @override
  String get naturalYogurt => 'Yogur natural';
  @override
  String get wheyProtein => 'Whey Protein';
  @override
  String get casein => 'Caseína';

  @override
  String get oliveOil => 'Aceite de oliva';

  @override
  String get peanutsPeanutButter => 'Maní / Mantequilla de maní';

  @override
  String get smallAvocado => 'Aguacate pequeño';

  @override
  String get sesameSeeds => 'Semillas de sésamo';

  @override
  String get extraVirginOliveOil => 'Aceite de oliva extra virgen';

  @override
  String get avocadoOil => 'Aceite de aguacate';

  @override
  String get almonds => 'Almendras';

  @override
  String get walnuts => 'Nueces';

  @override
  String get hassAvocado => 'Aguacate hass';

  @override
  String get organicChiaFlax => 'Chía/linaza orgánica';

  @override
  String get premiumNuts => 'Nueces premium';

  @override
  String get lard => 'Manteca';

  @override
  String get butter => 'Mantequilla';

  @override
  String get avocado => 'Aguacate';

  @override
  String get mctOil => 'Aceite MCT';

  @override
  String get gheeButter => 'Mantequilla ghee';

  @override
  String get olives => 'Aceitunas';

  @override
  String get avocadoHassAvocado => 'Aguacate / Aguacate hass';

  @override
  String get honey => 'Miel';

  @override
  String get darkChocolate70 => 'Chocolate 70%';

  @override
  String get pdfSuggestedRecipes => 'Recetas Sugeridas:';

  @override
  String get consumptionToday => 'Hoy llevas consumido';

  @override
  String caloriesRemaining(int calories) =>
      'Te faltan $calories kcal para el día';

  @override
  String get pdfProfileWeight => 'Peso';

  @override
  String get pdfProfileHeight => 'Talla';

  @override
  String get pdfProfileAge => 'Edad';

  @override
  String get pdfMacrosTargetTitle => 'Macros Objetivo';

  @override
  String get pdfPersonalizedMsgTitle => '¡Hola!:';

  @override
  String get pdfRecsTitle => 'Recomendaciones Generales y Tips';

  @override
  String get pdfRecsWeighingTitle => '* Pesaje de Alimentos:';

  @override
  String get pdfRecsWeighingBody1 => 'Proteínas: SIEMPRE se pesan en CRUDO';

  @override
  String get pdfRecsWeighingBody2 =>
      'Carbohidratos: Se pesan COCIDOS (excepto avena, crema de arroz, cereales = peso seco)';

  @override
  String get pdfRecsWeighingBody3 =>
      'Vegetales: Son libres, úsalos con variedad para sumar fibra';

  @override
  String get pdfRecsHydrationTitle => '* Hidratación y Medición:';

  @override
  String get pdfRecsHydrationBody1 =>
      'Agua: Consume 30-40 ml por cada kg de peso corporal al día';

  @override
  String get pdfRecsHydrationBody2 =>
      'Usa balanza digital y cucharas medidoras para mayor precisión';

  @override
  String get pdfRecsHydrationBody3 => '1 cucharada sopera = 15ml de aceite';

  @override
  String get pdfRecsHydrationBody4 => '1 taza = 250ml aproximadamente';

  @override
  String get pdfRecsOrgTitle => '* Organización:';

  @override
  String get pdfRecsOrgBody1 =>
      'Establece horarios fijos de comida y respétalos todos los días';

  @override
  String get pdfRecsOrgBody2 =>
      'Varía tus recetas e innova en la cocina para evitar la monotonía';

  @override
  String get pdfRecsOrgBody3 => 'Prepara salsas caseras a base de vegetales';

  @override
  String get pdfRecsOrgBody4 =>
      'Si tendrás un día complicado, adelanta tus comidas o llévalas contigo';

  @override
  String get pdfRecsKitchenTitle => '* Cocina:';

  @override
  String get pdfRemember => 'Recuerda:';

  @override
  String get pdfRememberBody1 =>
      '• Las porciones en tu plan ya están calculadas en el peso correcto (cocido o crudo según corresponda)';

  @override
  String get pdfRememberBody2 =>
      '• Si tienes dudas sobre cómo preparar un alimento, consulta con el chat de FRUTIA (tu nuevo nutricionista)';

  @override
  String get pdfRememberBody3 =>
      '• Este plan es personalizado para TI, no lo compartas sin ajustar para otras personas';

  @override
  String get pdfWelcomeDesc =>
      'Este plan ha sido diseñado específicamente para ti, tomando en cuenta tu objetivo, estilo de vida y preferencias alimentarias.';

  @override
  String pdfPersonalizedPlanTitle(String userName) =>
      'Plan de Alimentación Personalizado para $userName';

  @override
  String get contactSupport => 'Contacta a Frutia en WhatsApp: +1234567890';

  @override
  String get macroExcessWarning =>
      'Exceso de macronutrientes detectado - Toca para consejos';

  @override
  String macroExcessProtein(int amount) => 'Proteína: +${amount}g';

  @override
  String macroExcessCarbs(int amount) => 'Carbohidratos: +${amount}g';

  @override
  String macroExcessFats(int amount) => 'Grasas: +${amount}g';

  @override
  String get adviceTitle => 'Consejos Personalizados';

  @override
  String get adviceSubtitle => 'Basado en tus selecciones actuales:';

  @override
  String get adviceTip =>
      'Tip: Puedes deseleccionar opciones tocándolas nuevamente.';

  @override
  String recChangeToChicken(String meal, String option) =>
      'En $meal: Cambia "$option" por pollo (menos grasas)';

  @override
  String recChangeToBreast(String meal, String option) =>
      'En $meal: Cambia "$option" por pechuga de pollo';

  @override
  String recReducePortion(String meal, String option) =>
      'En $meal: Reduce porción de "$option" o cámbiala';

  @override
  String recSalmonFat(String meal, String option) =>
      'En $meal: "$option" tiene muchas grasas, prueba atún';

  @override
  String recReduceOil(String meal, String option) =>
      'En $meal: Reduce "$option" a 1 cucharada';

  @override
  String recReduceAlmonds(String meal, String option) =>
      'En $meal: Reduce porción de "$option" a la mitad';

  @override
  String recAvocado(String meal) =>
      'En $meal: Usa 1/4 de aguacate en lugar de la porción actual';

  @override
  String recReduceCarbs(String meal, String option) =>
      'En $meal: Reduce "$option" o omite carbohidratos en esta comida';

  @override
  String recReduceFruits(String meal, String option) =>
      'En $meal: Reduce porción de "$option" por el exceso de carbohidratos';

  @override
  String get autoAdjustError =>
      'No se puede calcular ajuste automático para esta porción';

  @override
  String get autoAdjustNoExcess => 'No hay exceso significativo para ajustar';

  @override
  String get autoAdjustTooAggressive =>
      'La reducción necesaria es demasiado grande. Te sugerimos cambiar de alimento.';

  @override
  String get pdfHowToUseStep1 => 'Seleccionar tus alimentos cada día';

  @override
  String get pdfHowToUseStep2 =>
      'Ver en tiempo real tus macronutrientes acumulados';

  @override
  String get pdfHowToUseStep3 => 'Advertirte ANTES de exceder tus límites';

  @override
  String get pdfHowToUseStep4 =>
      'Ajustar tu plan según tus preferencias diarias';

  @override
  String get pdfHowToUseTip =>
      'TIP: No todos los alimentos tienen el mismo aporte calórico. Por eso es crucial que uses la app para ir seleccionando lo que consumes.';

  @override
  String get pdfLearnToManipulateTitle => 'APRENDE A MANIPULAR TU DIETA';

  @override
  String get pdfLearnToManipulateDesc => 'Tu plan es FLEXIBLE. Puedes:';

  @override
  String get pdfLearnToManipulatePoint1 =>
      'Comer más en el desayuno y menos en la cena';

  @override
  String get pdfLearnToManipulatePoint2 =>
      'Distribuir tus macros como prefieras';

  @override
  String get pdfLearnToManipulatePoint3 =>
      'Variar tus alimentos cada día para no aburrirte';

  @override
  String get pdfLearnToManipulatePoint4 =>
      'Ajustar porciones según tu hambre (sin exceder macros)';

  @override
  String get pdfLearnToManipulateObjective =>
      'OBJETIVO: Que aprendas a medir tu plan y evitar excesos. La variedad de alimentos te ayudará a no saturarte.';

  @override
  String get pdfMealGroupsTitle => 'En cada comida encontrarás 3 grupos:';

  @override
  String get pdfImportantSelection =>
      'IMPORTANTE: NO selecciones todas las opciones. Solo UNA de cada grupo por comida.';

  @override
  String get pdfCookingTip =>
      'Cocina con aceite sin calorías o aceite de oliva extra virgen en mínima cantidad';

  @override
  String get errorNoActivePlan => 'No tienes un plan activo.';

  @override
  String get pdfWelcomeProtein => 'Proteínas: Elige UNA opción';

  @override
  String get pdfWelcomeCarbs => 'Carbohidratos: Elige UNA opción';

  @override
  String get pdfWelcomeFats => 'Grasas: Elige UNA opción';

  @override
  String get pdfSelectOneOptionTitle => 'SELECCIONA SOLO UNA OPCIÓN POR GRUPO';

  @override
  String adviceExceedMacrosNoMeals(String option) =>
      'Seleccionar "$option" excedería tus macros diarios. Como aún no has comido nada, considera redistribuir tus porciones en las próximas comidas.';

  @override
  String adviceExceedMacrosConsumed(
          int consumed, String option, int optionCal, int remaining) =>
      'Ya consumiste $consumed kcal hoy. "$option" ($optionCal kcal) excede tus $remaining kcal restantes. Deberías reducir otras comidas o elegir una opción más ligera.';

  @override
  String adviceExceedMacrosAllMeals(String option) =>
      'Has completado todas tus comidas del día y "$option" te haría exceder tu objetivo. Considera dejarlo para mañana o reduce la porción significativamente.';

  @override
  String adviceExceedMacrosRemaining(int consumed, String option, int optionCal,
          int remaining, int mealsLeft) =>
      'Llevas $consumed kcal consumidas. Si comes "$option" completo (${optionCal} kcal), te quedarán ${remaining - optionCal} kcal para $mealsLeft comida(s) más. Ajusta tus porciones en consecuencia.';

  @override
  String get mealBreakfast => 'Desayuno'; // ✅ CON MAYÚSCULA

  @override
  String get mealLunch => 'Almuerzo';

  @override
  String get mealDinner => 'Cena';

  @override
  String get mealSnackAm => 'Snack AM';

  @override
  String get mealSnackPm => 'Snack PM';

  @override
  String get mealShake => 'Shake';

  @override
  String get mealSnackFruit =>
      'Snack de frutas'; // ✅ Minúscula en "frutas" es correcto

  @override
  String get pdfHowToUsePlanTitle => 'CÓMO USAR TU PLAN';

  @override
  String get pdfYourObjectiveIs => 'Tu objetivo es:';

  @override
  String get modificationsSubtitle =>
      'Ajusta tu plan de alimentación y registra tu progreso.';

  @override
  String get editMyPlanTitle => 'Editar mi Plan';

  @override
  String get editMyPlanDescription =>
      'Aquí puedes ajustar tus preferencias de alimentación, objetivos, hábitos y más. Esto generará un plan nuevo basado en tus cambios.';

  @override
  String get editPlanButton => 'Editar Plan';

  @override
  String get updateProfileTitle => 'Actualizar Perfil';

  @override
  String get updateProfileDescription =>
      'Aquí puedes actualizar tu peso corporal y medir tu % de grasa. Esto ayudará a medir tu progreso.';

  @override
  String get updateProfileButton => 'Actualizar Perfil';

  @override
  String errorLoadingProfileWithMsg(String error) =>
      'Error al cargar tu perfil: $error';

  @override
  String get noImageSelected => 'No se seleccionó ninguna imagen.';

  @override
  String errorAnalyzingImageWithMsg(String error) =>
      'Error al analizar la imagen: $error';

  @override
  String get galleryPermissionDenied =>
      'Permiso a la galería denegado. Habilítalo en la configuración.';

  @override
  String get galleryPermissionRequired =>
      'El permiso a la galería es necesario para seleccionar una foto.';

  @override
  String get weightUpdatedSuccess => 'Peso actualizado correctamente.';

  @override
  String errorSavingWeightWithMsg(String error) =>
      'Error al guardar el peso: $error';

  @override
  String get congratsProgressTitle => '¡Felicidades por tu Progreso!';

  @override
  String get weightChangeDetected =>
      'Hemos notado un cambio significativo en tu peso.';

  @override
  String get recommendRecalculatePlan =>
      'Para asegurar que tu plan de alimentación siga siendo efectivo, te recomendamos recalcularlo.';

  @override
  String get later => 'Más tarde';

  @override
  String get bodyAnalysisTitle => 'Análisis Corporal';

  @override
  String get bodyAnalysisSubtitle =>
      'Sube una foto para una estimación de tu % de grasa corporal.';

  @override
  String get bodyAnalysisTip =>
      'Para un mejor resultado: Foto de cuerpo completo, en ropa interior o traje de baño, luz natural o buena iluminación';

  @override
  String get uploadPhoto => 'Subir Foto';

  @override
  String get uploadPhotoInstruction =>
      'Sube una imagen para ver tu resultado aquí.';

  @override
  String get progressRegistryTitle => 'Registro de Progreso';

  @override
  String get progressRegistrySubtitle =>
      'Actualiza tu peso para mantener tus métricas al día.';

  @override
  String get updatePlanNow => 'Actualizar Plan';

  @override
  String get notAvailable => 'No disponible';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get personalizedTipsTitle => 'Consejos Personalizados';

  @override
  String get anthropometricGuidanceTitle => 'Guía Antropométrica';

  @override
  String exceededBy(String amount) => 'Te pasaste por $amount';

  @override
  String get difficultySupportTitle => 'Apoyo para Dificultades';

  @override
  String get eatingOutGuidanceTitle => 'Comer Fuera de Casa';

  @override
  String get motivationTitle => 'Motivación';

  @override
  String get ageSpecificAdviceTitle => 'Consejo por Edad';

  @override
  String get dailyMacrosTitle => 'Tus Macros Diarios';

  @override
  String get caloriesLabel => 'Calorías';

  @override
  String get proteinLabel => 'Proteínas';

  @override
  String get carbsLabel => 'Carbs';

  @override
  String get fatsLabel => 'Grasas';

  @override
  String get recommendationsTitle => 'Recomendaciones';

  @override
  String errorLoadingRecipes(String e) => 'Error al cargar recetas: $e';

  @override
  String get premiumRequiredTitle => 'Necesitas ser PREMIUM';

  @override
  String get premiumRequiredSubtitle =>
      'Las recetas personalizadas están disponibles con la suscripción completa.';

  @override
  String get premiumUpgradeMessage =>
      'Activa tu suscripción para acceder a recetas paso a paso creadas específicamente para tu perfil.';

  @override
  String get upgradeButton => 'Actualizar';

  @override
  String get myRecipesTitle => 'Mis Recetas';

  @override
  String get inspirationTab => 'Inspiración';

  @override
  String get noRecipesAvailable => 'No hay recetas disponibles';

  @override
  String get upgradePlanButton => 'Actualizar Plan';

  @override
  String get searchRecipesHint => 'Buscar recetas...';

  @override
  String get allFilter => 'Todos';

  @override
  String get loadingImage => 'Cargando imagen...';

  @override
  String get noFormulasAvailable => 'No hay fórmulas disponibles.';

  @override
  String viewIdeasFor(String meal) => 'Ver Ideas para $meal';

  @override
  String get ingredientsTitle => 'Ingredientes';

  @override
  String get defaultIngredientName => 'Ingrediente';

  @override
  String get preparationTitle => 'Preparación';

  @override
  String servingsCount(int count) => '$count porciones';

  @override
  String get shoppingListTitle => 'Lista de compras';

  @override
  String get errorLoadingIngredients => 'Error al cargar ingredientes';

  @override
  String get retryButton => 'Reintentar';

  @override
  String get emptyShoppingList => 'Tu lista de compras está vacía.';

  @override
  String get generatePlanToSeeList =>
      'Genera un plan de alimentación para obtener tu lista.';

  @override
  String get noActivePlanError =>
      'No se encontró un plan de alimentación activo.';

  @override
  String get pdfRecsKitchenBody =>
      'Cocina con aceite sin calorías o aceite de oliva extra virgen en mínima cantidad';

  @override
  String get understoodButton => 'Entendido';

  @override
  String helloUser(String name) => '¡Hola, $name! 👋';

  @override
  String get suggestionsTitle => 'Sugerencias';

  @override
  String get vegetables => 'Vegetales';

  @override
  String get fruits => 'Frutas';

  @override
  String get kcal => 'kcal';

  @override
  String get proteinLabelShort => 'Proteína';

  @override
  String get carbsLabelShort => 'Carbohidrato';

  @override
  String get fatsLabelShort => 'Grasas';

  @override
  String get languageMismatchTitle => 'Preferencia de idioma';

  @override
  String get languageMismatchContent =>
      'El idioma de la aplicación es diferente al de tu dispositivo. ¿En qué idioma quieres tu plan?';

  @override
  String get useSpanish => 'Usar Español';

  @override
  String get snackAM => 'Snack AM';

  @override
  String get snackPM => 'Snack PM';

  @override
  String get completeMixedSalad => 'Ensalada completa mixta';

  @override
  String get steamedVegetablesBowl => 'Bowl de vegetales al vapor';

  @override
  String get mediterraneanSalad => 'Ensalada mediterránea';

  @override
  String get sauteedVegetables => 'Vegetales salteados';

  @override
  String get largeMixedGreenSalad => 'Ensalada verde mixta grande';

  @override
  String get cruciferousVegetablesSalad => 'Ensalada de vegetales crucíferos';

  @override
  String get lowCarbVegetablesMix => 'Mix de vegetales bajos en carbos';

  @override
  String get planReadyGoalReach =>
      '¡Tu plan está listo para que alcances tus metas!';
}
