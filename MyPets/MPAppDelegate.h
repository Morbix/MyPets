//
//  MPAppDelegate.h
//  MyPets
//
//  Created by Henrique Morbin on 23/10/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <Dropbox/Dropbox.h>
#import <Crashlytics/Crashlytics.h>

#import "ParcelKit.h"

@class MPMigrationManager;

@interface MPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIAlertView *notificationAlert;
@property (strong, nonatomic) PKSyncManager *syncManager;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)setSyncEnabled:(BOOL)enabled;

@end

//-Sync
//-Pendencias dos Warnings.
//-Remover o X dos banners.
//-Adicionar o X como banner antes de carregar o banner.
//-Forcar uso do Facebook.


//////////Sync Improvements
//-Local Notification to ask to finish sync
//-Keep all datas in one register

//////////Reviews
//-Se o seu pet morrer voce nao tem a opcao de manter o registro, apenas "jogar no lixo". Isso eh muito insensivel! Faltam outros registros que devem ser incluidos e ja comentados por outros.
//-Very helpful but it would have been better with a daily walk reminder
//-Vale muito a pena baixar, app completo. Só seria melhor se tivesse um campo para vitaminas, remédios de pulgas ou um campo editável. Fica a dica para próximas atualizações
//-Acho que falta características básicas. Eu poderia monitorar o cio da minha cadela e não existe esta opção. Outra, remédios mensais (para controle parasitário), não existe esta opção também... Achei bem primário... Poderia melhorar.
//-Estou aproveitando bem, mas seria bom se pudesse inserir outras anotações ou diário de ocorrências importantes da vida da minha Pet.
//-Ótimo app para acompanhar o desenvolvimento e vacinas do seus animais de estimação. Só falta um acompanhamento dos medicamentos e banhos (lembrar a cada X dias ou horas) e um histórico médico (doenças, cirurgias, alergias, etc)
//-Impossible d enregistrer une date répétitive ou une alerte sur plusieurs mois inutilisable pour les rappels de vaccin par exemple
//-Poderia permitir duplicar eventos para outras datas e outros pets (vacina e vermífugos por exemplo)
//-Gostei bastante muito útil, uma sugestão acho q poderia ter como fazer álbum de foto e vídeo tb.
//-Ótimo App !Funcional e muito bom, gostaria apenas de dar uma sugestão aos desenvolvedores, colocar a função de repetir para eventos que se repetem, tais como medicamentos e banhos.Obrigado realmente muito bom !
//-At first I was in love with this app...mostly because I was not only looking for an app to store my dogs medical records, but also satisfaction of backup security! This seems to be the only one with DropBox capability. However, aside from the attractive OS, it lacks many key features. No place for a microchip number, no place to add in when nail trims/anal gland expressions given etc. I work for a vet, so I wanted it all! The Facebook page is in Spanish and unfortunately I speak English...weird cause it doesn't say that in the beginning and I totally just downloaded the full version for $2.99! Oh well...I doubt they'll make changes. ...I looked into all apps similar and was so excited for this particular one too
//-Honestly I have searched the entire App Store for an app to compile all the medical info for my 3 dachshunds, and I have finally found it!! Working for a veterinary hospital and being a tad obsessed over my pooches, having their info is vital to me! This app is great, how beer, it has a couple quirks that could be ironed out, but definitely could be overlooked for the other features it has that others don't....for example, backup to Dropbox, and a beautiful interface to start!My only wishes would be to add some more to the "stats screen" on the animal/pet screen. There is no option to select neutered/spayed, color, or most importantly the microchip #! I also feel you should physically be able to type in the vaccination name in addition to adding a photo---rather than relying solely on the photo! If those things were fixed, it would be the best ever and I would buy the pro version and totally recommend it out to all my vet friends/colleagues!! =]
//-Muito bacana, não leva 5, porque quero ver ainda novas funções, uma agenda automatizada, espaço para tratamento das pulgas e com fotos, e galeria de fotos. Podia conversar com a agenda e contatos... Podia ter também espaço para incluir valores de tratamento, retornando custos mensais, anuais, médias, por setor e totalizacoes... Quer dizer seria definitivo, único e insubstituível.


//////////Backlog
//-Aviso para ativar as local notifications se nao os lembretes nao funcionam
//-Aviso para se tornar pro para remover as ads
//-Aviso para se cadastrar para acessar da web os dados
//-Aviso para se cadastrar para receber os alarmes por email
//-Aviso para se tornar pro para recuperar dados excluidos (se o mecanismo permitir)
//-Colocar o iD do usuario nas configurações para identificar
//-Enviar as notificacoes por email
//-Possibilitar alterar a ordem dos pets
//-Open Pet direto pela push notification
//-Persistencia das Push Notifications
//-Melhorar UI/Performance da tela inicial (collection)
//-Criar time line de acontecimentos, inclusive botao no registros para adicionar na timeline
//- Reativar Dropbox
//- Sync
//- Atualizar UI apenas quando voltar da tela
//- Itens dos emails
//- Local Push Badge Persistence
//- Push Notifications Persistence
//- Has New Version
//- Feedback visual para cadastrar um pet quando estiver vazio
//- Helpers First Visit
// -Repetir Evento
// -Controle de Peso com fotos
// -Código do Rastreador
// -Cio
// -Antipulgas
// -Albuns
// -Sync com facebook
// -Histórico do pet
// -Forma de Conversa com o Desenvolvedor
// -Ordenar tela inicial
// -Formato de lista para tela inicial
// -#warning Pendencias
//- Formato de Review do Felipe Oliveira
//- Fotos das Vacinas com overlay, ou ver foto inteira, ou reposicionar
//- Sync iCloud
//- Adicionar outras linguagens (Espanho, Frances, Italiano, Alemão)
//- Sistema de Ajuda pelo app inteiro
//- Otimização no CoreData transferindo arquivos de dados para outras entidades
//- algoritmo para sincronizar os alarmes: status nulo(não analisado), 1(sem lembrete), 2(com lembrete)(atenção ao implementar)
//- Cadastro de Veterinárias
//- Possibilidade de adicionar PDFs
//- Possibilidade de adicionar eventos gerais para os apps
//- Tracking de passeios (MyWay)
//- Lembretes com recorrência
//- Lembrete Geral de Vacina!
//- Cadastro do Cio das Fêmeas
//- Anexar o Pedigree em PDF
//- Contatos dos veterinários e veterinárias 24hs
//- Tela dos próximos eventos
//- Instapets, Petsgram (trazer mais interações)
//- Possibilidade de Selecionar formato de Grid ou Lista na tela Principal
//- Possibilidade de Exportar os dados como um Relatório
//- Criar sistema de compartilhamento do pet com outros usuários através de um arquivo
//- Controle Financeiro com os gastos com o Cão
//- Cálculo de Ração de acordo com o peso
//- Exportar
//- Informacoes Adicionais vinda de parceiros
//- Add Frances, Italiano, Espanhol
//-@3x



//2.2.1
//Ok - Atualizar Parse
//Ok - Atualizar Facebook
//Ok - Atualizar Bolts
//Ok - Adicionar arquiteturas
//Ok - Remover NSLogs
//Ok - crashlytics
//Ok - Atualizar AdMob
//OK - MXGoogleAnalytics
//Ok - idfa
//Ok - Notification iOS 8
//Ok - Tag de Ads Removed correta
//Ok - Habilitar compra apenas nos status corretos de transaction
//Ok - Usuario Anonimo
//Ok - Device Information


//2.2.0
//Ok - **** MyPet iPad ****
//Ok - Bug do popup foto
//Ok - Bug dos elementos centralizados
//Ok - Conversor AdMob
//Ok - GA Hit In-app Purchase Succeed
//Ok - Conversor Facebook
//Ok - Schema Facebook
//Ok - Close Button Ads
//Ok - In-App Remove Ads
//Ok - Clique do gráfico
//Ok - Clique na foto do Pet para editar
//Ok - Bug Ads
//Ok - Ads separadas para iPad
//OK - BUG nas ADS
//Ok - Replicar correcao do BUG
//Ok - Icones iPad

//2.1.2
//Ok - Clicar na foto do pet e mostrar fullscrenn + tracking analytics
//Ok - Delay na tela principal para tentar parar de dar crash

//2.1.1
//Ok - Bug da data de nascimento futura
//Ok - Bug do formato americano
//Ok - Status do Dropbox com notificações visuais
//Ok - Verificar track do erro no dropbox
//Ok - Corrigir link do Rate, Appirater atualizado
//Ok - Implementar Ads do FelipeOliveira, checa iAd else AdMob
//Ok - Versão iPad

//2.1.0
//Ok - Prints da app stora melhor com gatos
//Ok - Melhor descricao com reviews, mídia e posicoes
//Ok - Free e Pago -ATENCAO, tem que duplicar appirater, remover ads, analytics
//Ok - Ativar iAds apenas no FREE
//Ok - Setar o Parse para o mesmo nos dois
//Ok - Inscrever usuario em canais distintos
//Ok - PageViewTrack nos viewDidAppear
//Ok - Analytics Track - Dropbox connect e desconnect
//Ok - Analytics Track - e pageview nas configuracoes (todos os abouts) e lembretes
//Ok - Criar um track ou PageView também para os status do SKStore Clicou e Carregou
//Ok - Tela de Configuração com link para app pago para tirar propagandas
//Ok - About Me (versao, novidades, pagina do face, mais apps, email de contato)
//Ok - Alterar imagem do clock
//Ok - Badge na collection do numero de upcoming
//Ok - Lembretes Programados
//Ok - Ordem por nome
//Ok - redimensionar fotos ao salvar
//Ok - Tradução da tela configuracoes
//Ok - Diminuicão do tamanho do banco interno
//Ok - Foto de vermífugo padrao
//Ok - Correção de bug do Evento Lembretes
//Ok - Melhorar sombra
//Ok - Evento significante ao add pet Appirater
//Ok - Dropbox
//Ok - iAds
//Ok - FIX - nao salvar foto padrao nas vacinas e vermifugos
//Ok - FIX - limpar sem animal
//Ok - redimensionar fotos na entrada
//Ok - Peso - arrays e upcomings
//Ok - Gráfico
//Ok - Analytics Track - Peso

//2.0
//Ok - Ads
//Ok - Parse Notification
//Ok - GoogleAnalytics
//Ok - AppIRater