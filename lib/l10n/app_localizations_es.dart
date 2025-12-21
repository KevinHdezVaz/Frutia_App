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
  String get personalData => 'Datos Personales';

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
}
