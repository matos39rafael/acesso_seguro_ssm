# Fundação de Rede Segura na AWS

Laboratório desenvolvido com **Terraform** para demonstrar a criação de uma fundação de rede segura na AWS, distribuída entre múltiplas Availability Zones, com workloads privados e acesso administrativo por meio do **AWS Systems Manager Session Manager**.

## Objetivo

O laboratório tem como objetivo demonstrar:

- provisionamento de infraestrutura com Terraform;
- segmentação entre subnets públicas e privadas;
- workloads sem IPv4 público;
- administração sem exposição da porta SSH;
- uso de NAT Instances para conectividade de saída;
- controle de tráfego com Security Groups;
- distribuição de recursos entre duas Availabilityl Zones;
- validação por meio de testes funcionais e cenários de falha.

## Arquitetura

A infraestrutura utiliza uma VPC distribuída entre duas Availability Zones.

Cada AZ possui:

- uma subnet pública;
- uma subnet privada de aplicação;
- uma subnet privada de banco de dados;
- uma NAT Instance para saída à Internet.

As instâncias privadas não possuem IP público. O acesso administrativo é realizado por meio do AWS Systems Manager Session Manager.


## Principais decisões

### Workloads privados

As instâncias de aplicação são executadas em subnets privadas e não recebem IPv4 público.

### Administração sem SSH

O acesso administrativo utiliza AWS Systems Manager Session Manager, eliminando a necessidade de expor a porta TCP/22 e distribuir chaves SSH.

### NAT Instance

Foi utilizada uma NAT Instance por Availability Zone como alternativa de menor custo ao NAT Gateway em um ambiente de laboratório.

Essa escolha reduz custos, mas aumenta a responsabilidade operacional, pois exige configuração e manutenção da própria instância.

## Segurança

Os principais controles aplicados são:

- ausência de IP público nas instâncias privadas;
- ausência de acesso SSH exposto;
- segmentação por subnets;
- Security Groups com regras restritivas;
- IAM Roles para integração com o Systems Manager;
- acesso administrativo baseado em IAM.

## Disponibilidade

A arquitetura é distribuída entre duas Availability Zones.

Cada AZ possui sua própria NAT Instance, evitando que workloads de uma zona dependam da NAT localizada em outra.

O laboratório não implementa alta disponibilidade completa de aplicação, como Load Balancer, Auto Scaling ou banco Multi-AZ.

## Custos

Os principais componentes com potencial de cobrança são:

- EC2;
- EBS;
- IPv4 público;
- transferência de dados;
- CloudWatch.

O uso de NAT Instance foi adotado principalmente para reduzir custos durante os testes.


## Testes

Os principais testes realizados incluem:

- validação de ausência de IP público;
- validação de ausência de acesso SSH;
- acesso administrativo via SSM;
- conectividade de saída por meio da NAT Instance;
- validação das tabelas de rota;
- validação de `Source/Destination Check` desabilitado na NAT.

## Cenários de falha

O laboratório também prevê falhas controladas, como:

- remoção da rota para a NAT;
- indisponibilidade da NAT Instance;
- habilitação incorreta de Source/Destination Check;
- alteração de Security Groups;
- remoção das permissões necessárias ao SSM.

Esses testes ajudam a compreender o comportamento da arquitetura e a desenvolver uma metodologia estruturada de troubleshooting.

## Troubleshooting

A investigação de problemas segue uma abordagem por camadas:

```text
Application
    ↓
DNS
    ↓
Operating System
    ↓
Security Group
    ↓
Subnet / Route Table
    ↓
NAT
    ↓
Internet Gateway
    ↓
Destination
```

## Lições aprendidas

O laboratório reforça conceitos importantes de arquitetura AWS:

- workloads privados não precisam de SSH para administração;
- IAM e SSM reduzem a superfície de ataque;
- roteamento e controle de acesso são camadas distintas;
- Multi-AZ não significa automaticamente alta disponibilidade;
- NAT Instance reduz custos, mas aumenta responsabilidade operacional;
- Infrastructure as Code facilita deployment, recuperação e identificação de drift.


## Melhorias futuras

Possíveis evoluções:

- VPC Endpoints;
- NAT Gateway;
- VPC Flow Logs;
- CloudWatch Alarms;
- CloudTrail;
- AWS Config;
- GuardDuty;
- Inspector;
- Application Load Balancer;
- Auto Scaling;
- banco Multi-AZ;
- remote state do Terraform.

