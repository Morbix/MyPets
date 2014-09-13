//
//  MPAppDelegate.h
//  MyPets
//
//  Created by Henrique Morbin on 23/10/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParcelKit.h"

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


//Ok - **** MyPet iPad ****
//Ok - Bug do popup foto
//Ok - Bug dos elementos centralizados
//
// - Conversor AdMob
// - GA Hit In-app Purchase Succeed
// - Conversor Facebook
// - Schema Facebook
// - Close Button Ads
//Ok - In-App Remove Ads
//Ok - Clique do gráfico
//Ok - Clique na foto do Pet para editar
//Ok - Bug Ads
//Ok - Ads separadas para iPad
//OK - BUG nas ADS
// - Replicar correcao do BUG
// - Local Push Badge Persistence
//- Push Notifications Persistence
//- Has New Version
//- Feedback visual para cadastrar um pet quando estiver vazio
//- Helpers First Visit

//
//Repetir Evento
//Controle de Peso com fotos
//Código do Rastreador
//Cio
//Antipulgas
//Albuns
//Sync com facebook
//Histórico do pet
//#warning Pendencias
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
//###Alta
//###Média
//- Versão iPad
//- Formato de Review do Felipe Oliveira
//- Fotos das Vacinas com overlay, ou ver foto inteira, ou reposicionar
//- Sync iCloud
//- Adicionar outras linguagens (Espanho, Frances, Italiano, Alemão)
//- Sistema de Ajuda pelo app inteiro
//- Otimização no CoreData transferindo arquivos de dados para outras entidades
//###Baixa
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

//2.1.0
//---Publicacao
//---Desenvolvimento
//---Oks
//Ok - Prints da app stora melhor com gatos
//Ok - Melhor descricao com reviews, mídia e posicoes
//Ok - Free e Pago -ATENCAO, tem que duplicar appirater, remover ads, analytics
//Ok - Ativar iAds apenas no FREE
//Ok - Setar o Parse para o mesmo nos dois
//Ok - Inscrever usuario em canais distintos
//Nada - Teste quando atualizar dropbox o q fazer com os pets sendo atualizados
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



//Later
//Exportar
//Informacoes Adicionais vinda de parceiros
//Add Frances, Italiano, Espanhol

//Events
//Ok - Telas
//Ok - Add com total de itnes
//Ok - Delecoes
//Ok - Fotos
//Ok - Lembretes
//Ok - Dropbox connect e desconnect
//Peso
//Ok - Event track e pageview nas configuracoes e lembretes
//warning Pendencias